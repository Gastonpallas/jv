extends Button

var base_scale = Vector2.ONE
var hover_scale = Vector2(1.15, 1.15)  # 15% plus grand
var tween: Tween

func _ready() -> void:
	base_scale = scale
	pivot_offset = size / 2   # 🔥 centre le pivot du scale
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", hover_scale, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", base_scale, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
