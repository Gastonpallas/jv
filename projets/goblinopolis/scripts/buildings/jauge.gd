extends Node2D

var timer := 0.0
var delay := 1.0

func _process(delta):
	timer = clamp(timer + delta, 0.0, delay)
	queue_redraw()

func _draw():
	var percent: float = clamp(timer / delay, 0.0, 1.0)
	var w = 48
	var h = 6
	draw_rect(Rect2(Vector2(-w/2, -32), Vector2(w, h)), Color(0, 0, 0, 0.3))
	draw_rect(Rect2(Vector2(-w/2, -32), Vector2(w * percent, h)), Color(0.2, 1, 0.2, 0.7))
