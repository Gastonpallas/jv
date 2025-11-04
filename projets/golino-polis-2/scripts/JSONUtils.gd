extends Node

class_name JSONUtils

static func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Fichier introuvable: %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(text)
	if data is Dictionary:
		return data as Dictionary
	push_error("Le JSON n’est pas un dictionnaire en racine.")
	return {}
	
static func save_json(path: String, data: Dictionary) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()
	else:
		push_error("Impossible d’écrire dans %s" % path)
