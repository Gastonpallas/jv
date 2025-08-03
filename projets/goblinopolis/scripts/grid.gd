extends Node2D

@export var cell_size = 64
var cells = {}

@export var lumber_camp_scene: PackedScene
var batiment_selectionne = ""
var mode_demolition = false

func set_batiment_selectionne(type: String):
	if type == "demolir":
		mode_demolition = true
	else:
		mode_demolition = false
		batiment_selectionne = type

func _ready():
	queue_redraw()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var cell = world_to_cell(mouse_pos)

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
		_:
			print("Bâtiment inconnu :", batiment_selectionne)
			return

	# ✅ Appelle la méthode de vérification avant affichage
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
