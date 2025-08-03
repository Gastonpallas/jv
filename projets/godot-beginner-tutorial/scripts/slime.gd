extends AnimatedSprite2D

@onready var ray_cast_right: RayCast2D = $rayCastRight
@onready var ray_cast_left: RayCast2D = $rayCastLeft
@onready var slime: AnimatedSprite2D = $"."

const SPEED = 60
var direction = 1

func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		slime.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		slime.flip_h = false
	position.x += direction * SPEED * delta
