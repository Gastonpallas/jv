extends Control
@onready var rows_building_box: VBoxContainer = $VBoxContainerBuildings/Rows
var building_row_scene: PackedScene = preload("res://scenes/BuildingRow.tscn")

@onready var rows_ressource_box: VBoxContainer = $VBoxContainerRessources/Rows
var ressource_row_scene: PackedScene = preload("res://scenes/RessourceRow.tscn")



func _ready() -> void:
	var data_building := load_json("res://data/buildings.json")
	var buildings : Variant = data_building.get("buildings", [])
	
	var data_resspurces := load_json("res://data/ressources.json")
	var ressources : Variant = data_resspurces.get("ressources", [])

	for b in buildings:
		var row := building_row_scene.instantiate() as BuildingRow
		rows_building_box.add_child(row)

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
	
func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Fichier introuvable: %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(text)
	if typeof(data) == TYPE_DICTIONARY:
		return data
	push_error("Le JSON n’est pas un dictionnaire en racine.")
	return {}
