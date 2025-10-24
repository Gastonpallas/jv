extends Control
@onready var rows_box: VBoxContainer = $VBoxContainerBuildings/Rows
var row_scene: PackedScene = preload("res://scenes/BuildingRow.tscn")

func _ready() -> void:
	var row: BuildingRow = row_scene.instantiate()
	rows_box.add_child(row)
	row.set_values("LumberJack", 2.0, "wood", 0.0, "", 10.0, "planks", 0)
