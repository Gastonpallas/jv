extends CanvasLayer

@onready var res_label: Label = $ressources

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var gs = get_node("/root/Main/GameState")
	var bois = gs.resources["bois"]
	var ouv_dispo = gs.get_ouvriers_disponibles()
	var ouv_total = gs.resources["ouvriers_total"]
	res_label.text = "Bois : %d   |   Ouvriers : %d / %d" % [bois, ouv_dispo, ouv_total]
