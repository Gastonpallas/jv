extends Control

const JSON_BUILDINGS := "user://buildings.json"
const JSON_RESSOURCES := "user://ressources.json"

@onready var rows_building_box: VBoxContainer = $VBoxContainerBuildings/Rows
var building_row_scene: PackedScene = preload("res://scenes/BuildingRow.tscn")

@onready var rows_ressource_box: VBoxContainer = $VBoxContainerRessources/Rows
var ressource_row_scene: PackedScene = preload("res://scenes/RessourceRow.tscn")

var data_building: Dictionary = {}
var building_row_by_id: Dictionary = {}  # "id" -> BuildingRow

var data_ressources: Dictionary = {}
var ressource_row_by_id: Dictionary = {}

func _ready() -> void:
	data_building = JSONUtils.load_json(JSON_BUILDINGS)
	var buildings: Array = data_building.get("buildings", [])
	_build_building_rows(buildings)
	
	data_ressources = JSONUtils.load_json(JSON_RESSOURCES)
	var ressources: Array = data_ressources.get("ressources", [])
	_build_ressource_rows(ressources)
	
	
func _build_ressource_rows(ressources: Array) -> void:
	for ressource in ressources:
		var row = ressource_row_scene.instantiate() as RessourcRow
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
			print("ok")

			# 2) sauvegarder la nouvelle valeur
			JSONUtils.save_json(JSON_BUILDINGS, data_building)
			JSONUtils.save_json(JSON_RESSOURCES, data_ressources)


			# 3) MAJ visuelle immédiate de la ligne affichée
			if building_row_by_id.has(building_id):
				building_row_by_id[building_id].set_qty(new_qty)
			
			
			return
