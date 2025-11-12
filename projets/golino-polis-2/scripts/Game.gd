extends Control

const JSON_BUILDINGS := "user://buildings.json"
const JSON_RESSOURCES := "user://ressources.json"

@onready var rows_building_box: VBoxContainer = $VBoxContainerBuildings/Rows
var building_row_scene: PackedScene = preload("res://scenes/BuildingRow.tscn")

@onready var rows_ressource_box: VBoxContainer = $VBoxContainerRessources/Rows
var ressource_row_scene: PackedScene = preload("res://scenes/RessourceRow.tscn")

var data_building: Dictionary = {}
var building_row_by_id: Dictionary = {}

var data_ressources: Dictionary = {}
var ressource_row_by_id: Dictionary = {}

var acc_by_res: Dictionary = {} # rid -> float


func _ready() -> void:
	data_building = JSONUtils.load_json(JSON_BUILDINGS)
	var buildings: Array = data_building.get("buildings", [])
	_build_building_rows(buildings)
	
	data_ressources = JSONUtils.load_json(JSON_RESSOURCES)
	var ressources: Array = data_ressources.get("ressources", [])
	_build_ressource_rows(ressources)
	_recompute_resources_from_buildings()
	
	for r in data_ressources.get("ressources", []) as Array:
		var rid := str((r as Dictionary).get("id",""))
		acc_by_res[rid] = 0.0
	
func _build_ressource_rows(ressources: Array) -> void:
	for ressource in ressources:
		var row = ressource_row_scene.instantiate() as RessourceRow
		rows_ressource_box.add_child(row)
		
		var id   := str(ressource.get("id", ""))
		var name := str(ressource.get("name", ""))
		var prod := float(ressource.get("prod", 0))
		var dem  := float(ressource.get("dem",  0))
		var balance := float(ressource.get("balance", 0))
		var qty  := int(ressource.get("qty", 0))
		
		row.set_values( name, prod, dem, balance, qty)
		ressource_row_by_id[id] = row

func _build_building_rows(buildings: Array) -> void:
	for b in buildings:
		var row := building_row_scene.instantiate() as BuildingRow
		rows_building_box.add_child(row)

		var id   := str(b.get("id", ""))
		var name := str(b.get("name", ""))
		var prod : Dictionary = b.get("prod", {})
		var dem  : Dictionary = b.get("dem",  {})
		var cost : Dictionary = b.get("cost", {})
		var qty  := int(b.get("qty", 0))

		row.building_id = id
		row.set_values(
			name,
			float(prod.get("amount", 0.0)), str(prod.get("unit","")),
			float(dem.get("amount", 0.0)),  str(dem.get("unit","")),
			float(cost.get("amount", 0.0)), str(cost.get("unit","")),
			qty
		)

		# mémoriser la référence et connecter le signal
		building_row_by_id[id] = row
		row.add_pressed.connect(_on_add_pressed)
		row.subtract_pressed.connect(_on_subtract_pressed)

func _on_add_pressed(building_id: String) -> void:
	_building_management(building_id, 1)

func _on_subtract_pressed(building_id : String) -> void:
	_building_management(building_id, -1)

func _building_management(building_id : String, qty : int) -> void :
	# 1) +1 dans les données en mémoire
	var buildings: Array = data_building.get("buildings", [])
	for b in buildings:
		if str(b.get("id","")) == building_id:
			
			if qty > 0 :
				#Vérifier que on a assez de ressources pour construire 			
				var ressource_needed = b.get("cost").get("unit")
				var amount_needed = b.get("cost").get("amount")
				
				for ressource in data_ressources.get("ressources", []):
					if(ressource.get("id") == ressource_needed):
						
						var new_ressource_amount = int(ressource.get("qty", 0)) - amount_needed
						
						if(new_ressource_amount < 0):
							print("not enough ressources")
							return
						ressource["qty"] = new_ressource_amount
						ressource_row_by_id[ressource_needed].set_quantity(new_ressource_amount)

			var new_qty := int(b.get("qty", 0)) + qty
			if(new_qty < 0 ):
				new_qty = 0
			b["qty"] = new_qty

			# 2) sauvegarder la nouvelle valeur
			JSONUtils.save_json(JSON_BUILDINGS, data_building)
			JSONUtils.save_json(JSON_RESSOURCES, data_ressources)


			# 3) MAJ visuelle immédiate de la ligne affichée
			if building_row_by_id.has(building_id):
				building_row_by_id[building_id].set_qty(new_qty)
			
			_recompute_resources_from_buildings()
			return
			
func _recompute_resources_from_buildings() -> void:
	# Agrégats prod/dem par ressource
	var totals: Dictionary = {}  # { rid: { "prod": float, "dem": float } }

	var buildings: Array = data_building.get("buildings", []) as Array
	for b in buildings:
		var bd: Dictionary = b as Dictionary
		var qty: int = int(bd.get("qty", 0))
		if qty <= 0:
			continue

		var prod: Dictionary = bd.get("prod", {}) as Dictionary
		var dem:  Dictionary = bd.get("dem",  {}) as Dictionary

		var p_unit: String = str(prod.get("unit", ""))
		var d_unit: String = str(dem.get("unit",  ""))

		var p_amt: float = float(prod.get("amount", 0.0)) * qty
		var d_amt: float = float(dem.get("amount",  0.0)) * qty

		if p_unit != "" and p_unit != "—":
			if not totals.has(p_unit):
				totals[p_unit] = {"prod": 0.0, "dem": 0.0}
			var entry_p: Dictionary = totals[p_unit] as Dictionary
			entry_p["prod"] = float(entry_p.get("prod", 0.0)) + p_amt

		if d_unit != "" and d_unit != "—":
			if not totals.has(d_unit):
				totals[d_unit] = {"prod": 0.0, "dem": 0.0}
			var entry_d: Dictionary = totals[d_unit] as Dictionary
			entry_d["dem"] = float(entry_d.get("dem", 0.0)) + d_amt

	# Appliquer aux ressources + UI
	var ressources: Array = data_ressources.get("ressources", []) as Array
	for r in ressources:
		var rd: Dictionary = r as Dictionary
		var rid: String = str(rd.get("id", ""))

		# rec est un Variant -> on caste en Dictionary
		var rec: Dictionary = totals.get(rid, {"prod": 0.0, "dem": 0.0}) as Dictionary
		var prod_total: float = float(rec.get("prod", 0.0))
		var dem_total:  float = float(rec.get("dem",  0.0))
		var balance:    float = prod_total - dem_total

		# maj des données en mémoire (si tu veux persister)
		rd["prod"] = prod_total
		rd["dem"] = dem_total
		rd["balance"] = balance

		# row est aussi un Variant -> on caste en RessourceRow
		if ressource_row_by_id.has(rid):
			var row: RessourceRow = ressource_row_by_id[rid] as RessourceRow
			if "set_prod" in row: row.set_prod(prod_total)
			if "set_dem" in row: row.set_dem(dem_total)
			if "set_balance" in row: row.set_balance(balance)

	# (optionnel) persister
	JSONUtils.save_json(JSON_RESSOURCES, data_ressources)


func _on_tick_timer_timeout() -> void:
	# 1) snapshot des stocks actuels
	var res_qty: Dictionary = {}  # id -> float
	var ressources: Array = data_ressources.get("ressources", []) as Array
	for r in ressources:
		var rd := r as Dictionary
		var rid: String = str(rd.get("id",""))
		res_qty[rid] = float(rd.get("qty", 0.0))

	# 2) simulateur par bâtiment (recettes)
	var buildings: Array = data_building.get("buildings", []) as Array
	for b in buildings:
		var bd := b as Dictionary
		var qty_buildings: int = int(bd.get("qty", 0))
		if qty_buildings <= 0:
			continue

		var prod: Dictionary = bd.get("prod", {}) as Dictionary
		var dem:  Dictionary = bd.get("dem",  {}) as Dictionary

		var p_unit: String = str(prod.get("unit",""))
		var d_unit: String = str(dem.get("unit",""))

		var p_amt_per: float = float(prod.get("amount", 0.0))   # quantité produite par bâtiment et par tick
		var d_amt_per: float = float(dem.get("amount",  0.0))   # quantité consommée par bâtiment et par tick

		# si pas d'input (—) on produit librement
		if d_unit == "" or d_unit == "—" or d_amt_per <= 0.0:
			if p_unit != "" and p_unit != "—":
				res_qty[p_unit] = float(res_qty.get(p_unit, 0.0)) + p_amt_per * qty_buildings
			continue

		# sinon, on limite par l'input dispo
		var have_input: float = float(res_qty.get(d_unit, 0.0))
		var need_input: float = d_amt_per * qty_buildings
		if need_input <= 0.0:
			continue

		# facteur de limitation 0..1 (combien du cycle peut-on réaliser)
		var f: float = clamp(have_input / need_input, 0.0, 1.0)
		if f <= 0.0:
			continue

		var input_used: float = need_input * f
		var output_gained: float = p_amt_per * qty_buildings * f

		# applique immédiatement (consomme avant produit)
		res_qty[d_unit] = max(0.0, have_input - input_used)
		if p_unit != "" and p_unit != "—":
			res_qty[p_unit] = float(res_qty.get(p_unit, 0.0)) + output_gained

	# 3) écrire les stocks et mettre à jour l’UI
	for r in ressources:
		var rd := r as Dictionary
		var rid: String = str(rd.get("id",""))
		var new_qty: float = float(res_qty.get(rid, 0.0))
		rd["qty"] = new_qty

		# MAJ visuelle
		if ressource_row_by_id.has(rid):
			var row: RessourceRow = ressource_row_by_id[rid] as RessourceRow
			row.set_quantity(new_qty)  # adapte si tu affiches des ints (str(int(new_qty)))

	# (optionnel) persister périodiquement, pas à chaque frame
	# JSONUtils.save_json(JSON_RESSOURCES, data_ressources)
