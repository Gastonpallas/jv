extends Control

@onready var fighter_card: Control = $FighterCard
@onready var opp_card: Control = $OppCard

func _ready() -> void:
	get_data()

func _on_button_return_pressed() -> void:
	back_to_manage_fighter()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		back_to_manage_fighter()

func back_to_manage_fighter():
	get_tree().change_scene_to_file("res://scenes/select_fight.tscn")


func get_data():
	var player_data: Dictionary
	var opponent_data: Dictionary

	# Charger le boxeur joueur
	var player_path = "user://boxeur_selectionne.save"
	if FileAccess.file_exists(player_path):
		var file = FileAccess.open(player_path, FileAccess.READ)
		player_data = file.get_var()
		file.close()
	else:
		push_error("❌ Fichier boxeur_selectionne.save introuvable")

	# Charger l’adversaire
	var opp_path = "user://opponent.save"
	if FileAccess.file_exists(opp_path):
		var file = FileAccess.open(opp_path, FileAccess.READ)
		opponent_data = file.get_var()
		file.close()
	else:
		push_error("❌ Fichier opponent.save introuvable")

	# Appliquer aux cartes
	if player_data:
		fighter_card.set_data(player_data)
	if opponent_data:
		opp_card.set_data(opponent_data)


func _on_fight_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/fight.tscn")
