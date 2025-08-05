extends Camera2D

@export var pan_speed := 1.0
@export var zoom_speed := 0.1
@export var zoom_min := 0.5
@export var zoom_max := 2.5
@export var speed := 500.0


var dragging := false
var drag_start := Vector2.ZERO

func _unhandled_input(event):
	# Zoom à la molette
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1.0 - zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 1.0 + zoom_speed
		zoom.x = clamp(zoom.x, zoom_min, zoom_max)
		zoom.y = clamp(zoom.y, zoom_min, zoom_max)

		# Début du clic-glisser
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			dragging = true
			drag_start = get_viewport().get_mouse_position()

		if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			dragging = false

func _process(delta):
	if dragging:
		var mouse_now = get_viewport().get_mouse_position()
		var delta_mouse = (drag_start - mouse_now) * pan_speed * zoom
		position += delta_mouse
		drag_start = mouse_now
		
	var dir := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1

	if dir != Vector2.ZERO:
		position += dir.normalized() * speed * delta
