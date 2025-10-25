extends Control
@onready var rows_building_box: VBoxContainer = $VBoxContainerBuildings/Rows
var building_row_scene: PackedScene = preload("res://scenes/BuildingRow.tscn")

@onready var rows_ressource_box: VBoxContainer = $VBoxContainerRessources/Rows
var ressource_row_scene: PackedScene = preload("res://scenes/RessourceRow.tscn")



func _ready() -> void:
	var row: BuildingRow = building_row_scene.instantiate()
	rows_building_box.add_child(row)
	row.set_values("LumberJack", 2.0, "wood", 0.0, "", 10.0, "planks", 1)
	
	var row2: RessourcRow = ressource_row_scene.instantiate()
	rows_ressource_box.add_child(row2)
	row2.set_values("Wood", 2.0, 0.0, 2.0, 10)
	
