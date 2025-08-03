extends Control
@onready var start: Control = $fond/VBoxContainer/Start
@onready var quit: Button = $fond/VBoxContainer/Quit

func _ready() -> void:
	start.text = "start"
	quit.text = "quit"
	#Input.set_custom_mouse_cursor(load("res://assets/cursor/Dark Gothic Arrow & Coss--cursor--SweezyCursors.png"))
	
	
	

	


func _on_start_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/port.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
