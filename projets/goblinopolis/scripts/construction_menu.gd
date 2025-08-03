extends HBoxContainer

@onready var grid: Node2D = $"../../Grid"
@onready var button_1: Button = $Button1
@onready var buttton_delete: Button = $ButttonDelete



func _ready():
	button_1.pressed.connect(_on_button_1_pressed)
	buttton_delete.pressed.connect(_on_buttton_delete_pressed)

func _on_button_1_pressed():
	_set_active_button(button_1)
	grid.set_batiment_selectionne("cabane")


func _on_buttton_delete_pressed() -> void:
	_set_active_button(buttton_delete)
	grid.set_batiment_selectionne("demolir")
	
	
func _set_active_button(active_btn: Button):
	for child in get_children():
		if child is Button:
			child.button_pressed = (child == active_btn)
