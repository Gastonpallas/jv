extends Control

@onready var fighter_card: Control = $FighterCard
@onready var opp_card: Control = $OppCard

	
func on_start_pressed() -> void:
	init_data()
	get_tree().change_scene_to_file("res://scenes/boxer_select.tscn")

func on_options_pressed() -> void:
		#TODO
		print("options")
		get_tree().change_scene_to_file("res://scenes/select_fight.tscn")
		
func on_exit_pressed() -> void:
		get_tree().quit()
		
func init_data():
	delete_data()
	save_default_data()
		
	

func delete_data():
	var files_to_clear = [
	"user://save_data.save",
	"user://boxeur_selectionne.save",
	"user://opponent.save",
	"user://variable.save"
	]	
	for path in files_to_clear:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			print("🗑️ Supprimé :", path)
		else:
			print("⚠️ Fichier non trouvé :", path)

func save_default_data():
	var data = {
		"money": 100,
		"reputation": 10,
		"balance": -10
		}
	var file = FileAccess.open("user://save_data.save", FileAccess.WRITE)
	file.store_var(data)
	file.close()
