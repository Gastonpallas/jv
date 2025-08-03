extends Control
@onready var portrait: TextureRect = $Panel/Portrait

@onready var opp_cards = [
	$Panel/HBoxContainer/OppCard1,
	$Panel/HBoxContainer/OppCard2,
	$Panel/HBoxContainer/OppCard3
]

func _ready() -> void:
	#Récupérer la catégorie de mon boxeur
	var fighter = get_fighter()
	#Récupérer les boxeurs à affronter dans cette catégorie
	var allOpps = get_opps(determine_weight_class(fighter))	
	var opps = choisir_boxeurs_random(allOpps, 3)
	#Associer les infos avec les cards
	update_data(opps, opp_cards)
	
	
func _on_button_return_pressed() -> void:
	back_to_manage_fighter()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		back_to_manage_fighter()

func back_to_manage_fighter():
	get_tree().change_scene_to_file("res://scenes/manage_fighter.tscn")


#get info opps
func get_fighter():
	var path = "user://boxeur_selectionne.save"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var boxeur = file.get_var()
		portrait.texture = load(boxeur["portrait"])
		return boxeur
func get_opps(wClass) -> Array :
	var path = "res://data/opps.json"
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	var wclassFighters = null;
	wclassFighters = json[wClass]
	return wclassFighters

func determine_weight_class(fighter) -> String:
	var weight = int(fighter["weight"]) 
	if(weight < 60):
		return "featherweight"
	if(weight < 70):
		return "lightweight"
	if(weight < 80):
		return "welterweight"
	if(weight < 90):
		return "middleweight"
	if(weight >= 90):
		return "heavyweight"
		
	return "null"

func choisir_boxeurs_random(boxeurs: Array, n: int) -> Array:
	boxeurs.shuffle()
	return boxeurs.slice(0, n)

func update_data(opps, node):
	for i in range(3):
		#infos
		node[i].get_node("Button/VBoxContainerInfos/LabelName").text = opps[i]["name"]
		node[i].get_node("Button/VBoxContainerInfos/LabelAge").text = str(int(opps[i]["age"])) + "y/o"
		node[i].get_node("Button/VBoxContainerInfos/LabelHeight").text = str(opps[i]["height"]) + "M"
		node[i].get_node("Button/VBoxContainerInfos/LabelCountry").text = opps[i]["country"]
		node[i].get_node("Button/VBoxContainerInfos/LabelRecord").text =  str(int(opps[i]["wins"])) + "-" + str(int(opps[i]["loses"]))
		node[i].get_node("Button/VBoxContainerInfos/LabelStance").text = opps[i]["stance"]
		node[i].get_node("Button/VBoxContainerInfos/LabelAlias").text = opps[i]["alias"]

		node[i].get_node("Button/Portrait").texture = load(opps[i]["portrait"])

		# stats
		node[i].get_node("Button/VBoxContainerStats/LabelStr").text = "💪 STRENGHT : " + str(int(opps[i]["stats"]["strength"]))
		node[i].get_node("Button/VBoxContainerStats/LabelSta").text = "♻️ STAMINA : " + str(int(opps[i]["stats"]["stamina"]))
		node[i].get_node("Button/VBoxContainerStats/LabelHp").text = "❤️ HP : " + str(int(opps[i]["stats"]["hp"]))
		node[i].get_node("Button/VBoxContainerStats/LabelSpd").text = "⚡ SPEED : " + str(int(opps[i]["stats"]["speed"]))
		node[i].get_node("Button/VBoxContainerStats/LabelTec").text = "🧠 TECHNIC : " + str(int(opps[i]["stats"]["technic"]))
		
		node[i].data = opps[i]
		node[i].connect("opp_card_pressed", Callable(self, "opp_card_selected"))
		
		
		
func opp_card_selected(card):
	save_opps(card)
	get_tree().change_scene_to_file("res://scenes/versus.tscn")
	
func save_opps(card):	
	var file = FileAccess.open("user://opponent.save", FileAccess.WRITE)
	file.store_var(card.data)
	file.close()
	#var file2 = FileAccess.open("user://opponent.save", FileAccess.READ)
	#var opponent_loaded = file2.get_var()
	#file2.close()
#
	#print("✅ Opponent loaded from save:")
	#print(opponent_loaded)
