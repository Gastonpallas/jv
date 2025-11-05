extends Control

const JSON_BUILDINGS := "user://buildings.json"

@onready var rows_building_box: VBoxContainer = $VBoxContainerBuildings/Rows
var building_row_scene: PackedScene = preload("res://scenes/BuildingRow.tscn")

var data_building: Dictionary = {}
var row_by_id: Dictionary = {}  # "id" -> BuildingRow

func _ready() -> void:
	data_building = JSONUtils.load_json(JSON_BUILDINGS)
	var buildings: Array = data_building.get("buildings", [])
	_build_building_rows(buildings)

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
		row_by_id[id] = row
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
			var new_qty := int(b.get("qty", 0)) + qty
			if(new_qty < 0 ):
				new_qty = 0
			b["qty"] = new_qty

			# 2) sauvegarder la nouvelle valeur
			JSONUtils.save_json(JSON_BUILDINGS, data_building)

			# 3) MAJ visuelle immédiate de la ligne affichée
			if row_by_id.has(building_id):
				row_by_id[building_id].set_qty(new_qty)
			return
