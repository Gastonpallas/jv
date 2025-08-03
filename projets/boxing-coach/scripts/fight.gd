extends Control

var player_stats: Dictionary
var opp_stats: Dictionary
var player_data: Dictionary
var opponent_data: Dictionary
var player_bonus: Dictionary
var opponent_bonus: Dictionary
var round := 1
var seconds = 0
var score_player = 0
var score_opp = 0
var judge1: Dictionary = {}
var judge2: Dictionary = {}
var judge3: Dictionary = {}
var orders_available : Dictionary = {}

@onready var button: Button = $Button
@onready var label: Label = $Label
@onready var player_bars: Control = $HBoxContainerPlayer/PlayerBars
@onready var opp_bars: Control = $HBoxContainerOpp/OppBars
@onready var ko_player: Label = $KOPlayer
@onready var ko_opp: Label = $KOOpp
@onready var result: Label = $Result
@onready var button_next: Button = $ButtonNext
@onready var combat_timer: Timer = $CombatTimer
@onready var order_1: Button = $OrderContainer/Order1
@onready var order_3: Button = $OrderContainer/Order3
@onready var order_2: Button = $OrderContainer/Order2



# START 

func _ready() -> void:
	
	var path = "res://data/styles.json"
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	orders_available = json["classic"]
	order_1.text = orders_available["1"]["name"]
	order_2.text = orders_available["2"]["name"]
	order_3.text = orders_available["3"]["name"]

	
	get_data()
	init_bars(player_stats, player_bars)
	init_bars(opp_stats, opp_bars)
	label.text = "ROUND " + str(round)

func get_data():
	var player_path = "user://boxeur_selectionne.save"
	if FileAccess.file_exists(player_path):
		var file = FileAccess.open(player_path, FileAccess.READ)
		player_data = file.get_var()
		player_bars.get_node("Portrait").texture = load(player_data["portrait"])
		file.close()
	else:
		push_error("❌ Fichier boxeur_selectionne.save introuvable")

	var opp_path = "user://opponent.save"
	if FileAccess.file_exists(opp_path):
		var file = FileAccess.open(opp_path, FileAccess.READ)
		opponent_data = file.get_var()
		opp_bars.get_node("Portrait").texture = load(opponent_data["portrait"])
		file.close()
	else:
		push_error("❌ Fichier opponent.save introuvable")

	player_stats = player_data["stats"]
	opp_stats = opponent_data["stats"]
	player_bonus = player_stats.duplicate(true)

func init_bars(stats: Dictionary, bars: Control):
	bars.get_node("VBoxContainer/BarHp").max_value = stats["hp"]
	bars.get_node("VBoxContainer/BarHp").value = stats["hp"]

	bars.get_node("VBoxContainer/BarSta").max_value = stats["stamina"]
	bars.get_node("VBoxContainer/BarSta").value = stats["stamina"]

	bars.get_node("VBoxContainer/BarSpd").max_value = stats["speed"]
	bars.get_node("VBoxContainer/BarSpd").value = stats["speed"]

	bars.get_node("VBoxContainer/BarStr").max_value = stats["strength"]
	bars.get_node("VBoxContainer/BarStr").value = stats["strength"]

	bars.get_node("VBoxContainer/BarTec").max_value = stats["technic"]
	bars.get_node("VBoxContainer/BarTec").value = stats["technic"]

# ROUNDS 

func _on_button_pressed() -> void:	
	score_player = 0
	score_opp = 0
	combat_timer.start()
	button.disabled = true
	

func update_bars():
	#HP
	player_bars.get_node("VBoxContainer/BarHp").value = max(player_stats["hp"], 0)
	opp_bars.get_node("VBoxContainer/BarHp").value = max(opp_stats["hp"], 0)
	
	#STRENGHT
	player_bars.get_node("VBoxContainer/BarStr").value = max(player_stats["strength"], 0)
	opp_bars.get_node("VBoxContainer/BarStr").value = max(opp_stats["strength"], 0)
	
	#SPEED
	player_bars.get_node("VBoxContainer/BarSpd").value = max(player_stats["speed"], 0)
	opp_bars.get_node("VBoxContainer/BarSpd").value = max(opp_stats["speed"], 0)
	
	#TEC
	player_bars.get_node("VBoxContainer/BarTec").value = max(player_stats["technic"], 0)
	opp_bars.get_node("VBoxContainer/BarTec").value = max(opp_stats["technic"], 0)
	
	#STAMINA
	player_bars.get_node("VBoxContainer/BarSta").value = max(player_stats["stamina"], 0)
	opp_bars.get_node("VBoxContainer/BarSta").value = max(opp_stats["stamina"], 0)

func fight():
	var player_throws := randf() < 0.5 # Add Speed
	var opp_throws := randf() < 0.5
	
	if(player_throws):
		player_stats["stamina"] -= 3
	else : player_stats["stamina"] += 1
	
	var player_lands := resolve_punch(true, player_throws)
	var opp_lands := resolve_punch(false, opp_throws)
	
	if player_lands:
		score_player += 1
	if opp_lands:
		score_opp += 1

	print("Score : ", score_player, " - ", score_opp)

func resolve_punch(is_player_attacker: bool, did_throw: bool) -> bool:
	if not did_throw:
		return false

	var attacker = player_bonus if is_player_attacker else opp_stats
	var defender = opp_stats if is_player_attacker else player_bonus

	var dodge_chance: int = defender["speed"]
	if randi_range(0, 99) >= dodge_chance:
		defender["hp"] = max(defender["hp"] - attacker["strength"] / 10, 0)
		return true
	return false

func _on_combat_timer_timeout() -> void:
	fight()
	update_bars()
	seconds += 1
	if(seconds >= 100):
		combat_timer.stop()
		score_round()
		round += 1
		label.text = "ROUND " + str(round)
		seconds = 0
		button.disabled = false
		
		if(round > 3):
			end()
		
func calculate_total_score(judge: Dictionary) -> Dictionary:
	var player_final_score = 0
	var opp_final_score = 0

	for round_result in judge.values():
		var split = round_result.split("-")
		player_final_score += int(split[0])
		opp_final_score += int(split[1])

	return {
		"player": player_final_score,
		"opp": opp_final_score
	}

func score_round():
	var round_key = "round" + str(round)

	# Chaque juge fait un choix, ici basé uniquement sur le score.
	for judge in [judge1, judge2, judge3]:
		if score_player > score_opp:
			judge[round_key] = "10-9"
		elif score_opp > score_player:
			judge[round_key] = "9-10"
		else:
			judge[round_key] = "10-10"  # égalité possible

func change_tactics(tactic_name : String):
	for key in orders_available.keys():
		var order = orders_available[key]
		if order["name"] == tactic_name:
			change_bonus(order)

func change_bonus(order : Dictionary):
	player_bonus = player_stats.duplicate(true)
	player_bonus["speed"] = max( player_bonus["speed"] * order["speed"] ,0)
	player_bonus["strength"] = max( player_bonus["strength"] * order["strength"] ,0)

# FIGHT ENDS

func update_gym(player_won: bool):
	var file = FileAccess.open("user://save_data.save", FileAccess.READ)
	var save_data = file.get_var()
	file.close()

	if player_won:
		save_data["money"] += 10
		save_data["reputation"] += 1
	else:
		save_data["money"] += 5
		save_data["reputation"] -= 1

	var write_file = FileAccess.open("user://save_data.save", FileAccess.WRITE)
	write_file.store_var(save_data)
	write_file.close()

func update_fighter(player_won: bool):
	var file = FileAccess.open("user://boxeur_selectionne.save", FileAccess.READ)
	var player_data = file.get_var()
	file.close()

	player_data["fatigue"] += 1

	if player_won:
		player_data["wins"] += 1
	else:
		player_data["loses"] += 1

	var write_file = FileAccess.open("user://boxeur_selectionne.save", FileAccess.WRITE)
	write_file.store_var(player_data)
	write_file.close()

func end():
	update_bars()
	
	var total1 = calculate_total_score(judge1)
	var total2 = calculate_total_score(judge2)
	var total3 = calculate_total_score(judge3)
	var player_wins = 0
	var opp_wins = 0

	for total in [total1, total2, total3]:
		if total["player"] > total["opp"]:
			player_wins += 1
		elif total["opp"] > total["player"]:
			opp_wins += 1
		else : 
			opp_wins +=1
			player_wins += 1

	if player_wins >= 2:
		result.text = "Victory by decision"
		update_gym(true)
		update_fighter(true)
	else:
		result.text = "Loss by decision"
		update_gym(false)
		update_fighter(false)
	result.visible = true
	button.visible = false
	button_next.visible = true
	
func _on_button_next_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gym.tscn")
	


func _on_order_1_pressed() -> void:
	change_tactics(order_1.text)

func _on_order_2_pressed() -> void:
	change_tactics(order_2.text)

func _on_order_3_pressed() -> void:
	change_tactics(order_3.text)
