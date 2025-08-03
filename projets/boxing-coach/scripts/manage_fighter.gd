extends Control

@onready var portrait: TextureRect = $Portrait
@onready var name_label: Label = $fond/HBoxContainer/VBoxContainer/NameLabel
@onready var height_label: Label = $fond/HBoxContainer/VBoxContainer/HeightLabel
@onready var weight_label: Label = $fond/HBoxContainer/VBoxContainer/WeightLabel
@onready var record_label: Label = $fond/HBoxContainer/VBoxContainer/RecordLabel
@onready var country_label: Label = $fond/HBoxContainer/VBoxContainer/CountryLabel
@onready var age_label: Label = $fond/HBoxContainer/VBoxContainer/AgeLabel
@onready var strenght_label: Label = $fond/HBoxContainer/VBoxContainerStats/StrenghtLabel
@onready var stamina_label: Label = $fond/HBoxContainer/VBoxContainerStats/StaminaLabel
@onready var hp_label: Label = $fond/HBoxContainer/VBoxContainerStats/HPLabel
@onready var speed_label: Label = $fond/HBoxContainer/VBoxContainerStats/SpeedLabel
@onready var technic_label: Label = $fond/HBoxContainer/VBoxContainerStats/TechnicLabel
@onready var radar_chart: Node2D = $RadarChart

func _ready() -> void:
	var path = "user://boxeur_selectionne.save"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var boxeur = file.get_var()
		portrait.texture = load(boxeur["portrait"])
		name_label.text += boxeur["name"]
		height_label.text += str(boxeur["height"]) + "m"
		weight_label.text += str(boxeur["weight"]) + "kg"
		record_label.text +=  str(int(boxeur["wins"])) + "-" + str(int(boxeur["loses"]))
		country_label.text += boxeur["country"]
		age_label.text +=  str(int(boxeur["age"]))
				# Stats (si elles existent)
		if boxeur.has("stats"):
			var stats = boxeur["stats"]
			strenght_label.text = "💪 STRENGTH : " + str(stats.get("strength", 0))
			stamina_label.text = "♻️ STAMINA : " + str(stats.get("stamina", 0))
			hp_label.text = "❤️ HP : " + str(stats.get("hp", 0))
			speed_label.text = "⚡ SPEED : " + str(stats.get("speed", 0))
			technic_label.text = "🧠 TECHNIC : " + str(stats.get("technic", 0))
							# Envoie au RadarChart
			if radar_chart.has_method("set_stats"):
				radar_chart.set_stats(stats)


func _on_button_return_pressed() -> void:
	back_to_gym()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		back_to_gym()

func back_to_gym():
	get_tree().change_scene_to_file("res://scenes/gym.tscn")


func _on_fight_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/select_fight.tscn")
