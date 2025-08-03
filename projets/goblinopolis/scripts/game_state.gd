extends Node

var resources = {}

const SAVE_PATH := "res://data/ressources.json"

func _ready():
	load_resources()

func load_resources():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		resources = JSON.parse_string(content)
		if resources == null:
			push_error("Erreur de parsing JSON")
	else:
		# fichier non trouvé → valeurs par défaut
		resources = {
			"bois": 20,
			"planches": 0,
			"viande": 0,
			"prisonniers": 0,
			"gobelins_nus": 0,
			"massues": 0,
			"gobelins_armés": 0,
			"ouvriers_total": 5,
			"ouvriers_utilisés": 0
		}
		save_resources()

func save_resources():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(resources, "\t"))

func ajouter_ressource(nom: String, quantite: int):
	if resources.has(nom):
		resources[nom] += quantite
		save_resources()

func consommer_ressource(nom: String, quantite: int) -> bool:
	if resources.get(nom, 0) >= quantite:
		resources[nom] -= quantite
		save_resources()
		return true
	return false

func get_ouvriers_disponibles() -> int:
	return resources["ouvriers_total"] - resources["ouvriers_utilisés"]

func consommer_ouvriers(n: int) -> bool:
	if get_ouvriers_disponibles() >= n:
		resources["ouvriers_utilisés"] += n
		save_resources()
		return true
	return false

func liberer_ouvriers(n: int):
	resources["ouvriers_utilisés"] = max(resources["ouvriers_utilisés"] - n, 0)
	save_resources()
