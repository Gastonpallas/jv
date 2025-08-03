extends Control
signal card_pressed

var boxeur_data: Dictionary

func _ready():
	$Button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	emit_signal("card_pressed", self)
	
