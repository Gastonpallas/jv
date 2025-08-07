extends Node2D

@onready var fond: TileMapLayer = $"../Fond"
@export var cell_size = 64
@export var lumber_camp_scene: PackedScene
@onready var preview_sprite: Sprite2D = $Preview/Sprite2D

var batiment_selectionne = ""
var mode_demolition = false
var cells = {}
var tuiles_contructibles = [0]

func set_batiment_selectionne(type: String):
	if type == "demolir":
		mode_demolition = true
		batiment_selectionne = type
	else:
		mode_demolition = false
		batiment_selectionne = type

func _ready():
	queue_redraw()

func _process(delta: float) -> void:
	if batiment_selectionne == "" or batiment_selectionne == "demolir":
		preview_sprite.visible = false
		return
	var cell = world_to_cell(get_global_mouse_position())
	var pos = cell_to_world(cell) + Vector2(cell_size / 2, cell_size / 2)

	preview_sprite.visible = true
	preview_sprite.position = pos 

	# Choisir sprite selon type de bâtiment sélectionné
	match batiment_selectionne:
		"cabane":
			preview_sprite.texture = preload("res://assets/images/buildings/LumberCamp_64x64.png")
		_:
			preview_sprite.texture = null

	# Détection zone valide
	var tile_id = fond.get_cell_source_id(cell)
	if tuiles_contructibles.has(tile_id) and not cells.has(cell):
		preview_sprite.modulate = Color(0.5, 1.0, 0.5, 0.7)  # vert translucide
	else:
		preview_sprite.modulate = Color(1.0, 0.3, 0.3, 0.7)  # rouge translucide

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var cell = world_to_cell(mouse_pos)
		
			# Vérifier si la cellule contient une tuile autorisée
		var tile_id = fond.get_cell_source_id(cell)

		if not tuiles_contructibles.has(tile_id):
			print("Zone non constructible ici")
			return
		
		if mode_demolition:
			if cells.has(cell):
				var building = cells[cell]
				building.queue_free()
				cells.erase(cell)
			else:
				print("Aucun bâtiment ici à détruire")
			return
		if not cells.has(cell):
			placer_batiment(cell)
		else:
			print("Déjà un bâtiment ici")

func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / cell_size), floor(pos.y / cell_size))

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * cell_size, cell.y * cell_size)

func placer_batiment(cell: Vector2i):
	var instance: Node2D
	match batiment_selectionne:
		"cabane":
			if lumber_camp_scene == null  :
				print("Scène de cabane non assignée")
				return
				
			instance = lumber_camp_scene.instantiate()
			preview_sprite.visible = false
		_:
			print("Bâtiment inconnu :", batiment_selectionne)
			return

	var gs = get_node("/root/Main/GameState")
	if instance.has_method("peut_construire") and not instance.peut_construire(gs):
		print("Construction refusée : conditions non remplies")
		return

	# Positionnement centré
	instance.position = cell_to_world(cell) + Vector2(cell_size / 2, cell_size / 2)
	add_child(instance)
	cells[cell] = instance

func _draw():
	for x in range(0, 20):
		for y in range(0, 12):
			var pos = Vector2(x * cell_size, y * cell_size)
			draw_rect(Rect2(pos, Vector2(cell_size, cell_size)), Color(1, 1, 1, 0.1), false)
