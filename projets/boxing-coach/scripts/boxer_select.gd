extends Control

@onready var fighter_cards = [
	$HBoxContainer/Fighter1,
	$HBoxContainer/Fighter2,
	$HBoxContainer/Fighter3
]

func _ready():
	var boxeurs = charger_boxeurs()
	var selection = choisir_boxeurs_random(boxeurs, 3)
	for i in range(3):
		remplir_card(fighter_cards[i], selection[i])

func charger_boxeurs() -> Array:
	var path = "res://data/fighters.json"
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	return json

func choisir_boxeurs_random(boxeurs: Array, n: int) -> Array:
	boxeurs.shuffle()
	return boxeurs.slice(0, n)

func remplir_card(card_node: Control, boxeur: Dictionary):
	card_node.get_node("Button/VBoxContainer/NameLabel").text = "NAME : " + boxeur["name"]
	card_node.get_node("Button/VBoxContainer/HeightLabel").text = "HEIGHT : " + str(boxeur["height"]) + "m"
	card_node.get_node("Button/VBoxContainer/WeightLabel").text = "WEIGHT : " + str(boxeur["weight"]) + "kg"
	card_node.get_node("Button/VBoxContainer/RecordLabel").text = "RECORD : " + str(int(boxeur["wins"])) + "-" + str(int(boxeur["loses"]))

	var texture = load(boxeur["portrait"])
	card_node.get_node("Button/Portrait").texture = texture

	card_node.boxeur_data = boxeur  # important si tu veux l’utiliser dans _on_card_selected
	card_node.connect("card_pressed", Callable(self, "_on_card_selected"))


func sauvegarder_boxeur(boxeur: Dictionary) -> void:
	var file = FileAccess.open("user://boxeur_selectionne.save", FileAccess.WRITE)
	file.store_var(boxeur)
	print("✅ Boxeur sauvegardé :", boxeur.name)

func _on_card_selected(card):
	var selected = card.boxeur_data
	sauvegarder_boxeur(selected)
	get_tree().change_scene_to_file("res://scenes/gym.tscn")



	
