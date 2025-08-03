extends Control

@onready var label_argent: Label = $Header/LabelArgent
@onready var label_reputation: Label = $Header/LabelReputation
@onready var portrait: TextureRect = $Footer/Button/Portrait
@onready var label_name: Label = $Footer/Button/LabelName
@onready var label_balance: Label = $Header/LabelBalance
@onready var fatigue_panel: Panel = $Footer/Button/FatiguePanel

var money: int
var reputation: int 
var balance: int

func _ready():
	var fighter = load_save("user://boxeur_selectionne.save")
	var gym_data = load_save("user://save_data.save")
	
	if fighter and gym_data:
		label_name.text = fighter["name"]
		portrait.texture = load(fighter["portrait"])
		money = gym_data["money"]
		reputation = gym_data["reputation"]
		balance = gym_data["balance"]
		update_ressources(fighter)

func update_ressources(fighter: Dictionary):
	label_argent.text = "Treasury  : " + str(money) + " $"
	label_reputation.text = "Reputation : " + str(reputation)
	label_balance.text = "Balance : " + str(balance) + " $"
	fatigue_panel.visible = fighter.get("fatigue", 0) > 0

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/manage_fighter.tscn")

func _on_time_button_pressed() -> void:
	var fighter = load_save("user://boxeur_selectionne.save")
	var gym_data = load_save("user://save_data.save")
	
	if fighter and gym_data:
		gym_data["money"] += gym_data["balance"]
		save_to_file("user://save_data.save", gym_data)
		
		if fighter.get("fatigue", 0) > 0:
			fighter["fatigue"] -= 1
		save_to_file("user://boxeur_selectionne.save", fighter)
		
		money = gym_data["money"]
		update_ressources(fighter)

# 🔁 UTILITAIRES -----------------------------

func load_save(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = file.get_var()
		file.close()
		return data
	return {}

func save_to_file(path: String, data: Dictionary) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()
