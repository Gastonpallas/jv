extends Control
@onready var rows_building_box: VBoxContainer = $VBoxContainerBuildings/Rows
var building_row_scene: PackedScene = preload("res://scenes/BuildingRow.tscn")

@onready var rows_ressource_box: VBoxContainer = $VBoxContainerRessources/Rows
var ressource_row_scene: PackedScene = preload("res://scenes/RessourceRow.tscn")



func _ready() -> void:
	var data_building := JSONUtils.load_json("res://data/buildings.json")
	var buildings : Variant = data_building.get("buildings", [])
	
	var data_resspurces := JSONUtils.load_json("res://data/ressources.json")
	var ressources : Variant = data_resspurces.get("ressources", [])

	for b in buildings:
		var row := building_row_scene.instantiate() as BuildingRow
		rows_building_box.add_child(row)

		var id := str(b.get("id", ""))
		var name := str(b.get("name", ""))
		var prod : Dictionary = b.get("prod", {})
		var dem  :Dictionary = b.get("dem",  {})
		var cost :Dictionary = b.get("cost", {})
		var qty  := int(b.get("qty", 0))

		row.set_values(
			name,
			float(prod.get("amount", 0.0)),
			str(prod.get("unit", "")),
			float(dem.get("amount", 0.0)),
			str(dem.get("unit", "")),
			float(cost.get("amount", 0.0)),
			str(cost.get("unit", "")),
			qty
		)
		
		row.building_id = id
		row.add_pressed.connect(_on_add_pressed)
	
	for r in ressources:
		var row := ressource_row_scene.instantiate() as RessourcRow
		rows_ressource_box.add_child(row)

		var name := str(r.get("name", ""))
		var prod := int(r.get("prod", 0))
		var dem  := int(r.get("dem", 0))
		var balance := int(r.get("balance", 0))
		var qty  := int(r.get("qty", 0))

		row.set_values(
			name,
			prod,
			dem,
			balance,
			qty
		)
	

func _on_add_pressed(building_id : String) -> void :
	var path := "user://buildings.json"
	var data = JSONUtils.load_json(path)
	var buildings: Array = data.get("buildings", [])
	for building in buildings:
		if building.get("id", "") == building_id:
			building["qty"] = int(building.get("qty", 0)) + 1
			print("Nouvelle quantité de", building_id, "=", building["qty"])
			break
	
	JSONUtils.save_json(path, data)
