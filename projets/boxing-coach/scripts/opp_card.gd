extends Control
signal opp_card_pressed

var data: Dictionary

func _ready():
	$Button.pressed.connect(_on_button_pressed)


func _on_button_pressed():
	emit_signal("opp_card_pressed", self)


func set_data(boxeur: Dictionary):
	data = boxeur
	
	# Affichage infos générales
	get_node("Button/VBoxContainerInfos/LabelName").text = boxeur["name"]
	get_node("Button/VBoxContainerInfos/LabelAge").text = str(int(boxeur["age"])) + " y/o"
	get_node("Button/VBoxContainerInfos/LabelHeight").text = str(boxeur["height"]) + " M"
	get_node("Button/VBoxContainerInfos/LabelCountry").text = boxeur["country"]
	get_node("Button/VBoxContainerInfos/LabelRecord").text = str(int(boxeur["wins"])) + "-" + str(int(boxeur["loses"]))
	get_node("Button/VBoxContainerInfos/LabelAlias").text = boxeur["alias"]
	get_node("Button/VBoxContainerInfos/LabelStance").text = boxeur["stance"]
	
	# Portrait
	get_node("Button/Portrait").texture = load(boxeur["portrait"])  
	
	# Affichage stats
	var stats = boxeur["stats"]
	get_node("Button/VBoxContainerStats/LabelStr").text = "💪 STRENGTH : " + str(stats["strength"])
	get_node("Button/VBoxContainerStats/LabelSta").text = "♻️ STAMINA : " + str(stats["stamina"])
	get_node("Button/VBoxContainerStats/LabelHp").text = "❤️ HP : " + str(stats["hp"])
	get_node("Button/VBoxContainerStats/LabelSpd").text = "⚡ SPEED : " + str(stats["speed"])
	get_node("Button/VBoxContainerStats/LabelTec").text = "🧠 TECHNIC : " + str(stats["technic"])
