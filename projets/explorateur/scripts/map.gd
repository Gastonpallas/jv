extends Node2D

const ETAGES = 5
const NODES_PAR_ETAGE = 3
const ESPACEMENT_X = 400
const ESPACEMENT_Y = 150

@onready var node_scene = preload("res://scenes/node_map.tscn")

func _ready():
	var screen_width = get_viewport().size.x
	var total_row_width = (NODES_PAR_ETAGE - 1) * ESPACEMENT_X
	var x_offset = (screen_width - total_row_width) / 2

	for y in range(ETAGES):
		for x in range(NODES_PAR_ETAGE):
			var node = node_scene.instantiate()
			var pos_x = x * ESPACEMENT_X + x_offset
			var pos_y = y * ESPACEMENT_Y + 100
			node.position = Vector2(pos_x, pos_y)
			add_child(node)
