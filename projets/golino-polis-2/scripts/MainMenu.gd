extends Control


func _on_start_btn_pressed() -> void:
	print("Nouvelle partie : réinitialisation des données...")

	var src_files = [
		"res://data/buildings.json",
		"res://data/ressources.json"
	]

	for src in src_files:
		var dest = "user://" + src.get_file()
		var data = JSONUtils.load_json(src)
		JSONUtils.save_json(dest, data)
		print("Copié (ou écrasé) vers :", dest)

	get_tree().change_scene_to_file("res://scenes/Game.tscn")
