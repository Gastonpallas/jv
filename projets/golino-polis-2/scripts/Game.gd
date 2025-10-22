extends Control

@onready var rows_box = $VBoxContainer/Rows
@onready var row_scene: PackedScene = preload("res://scenes/TableRow.tscn")

# --- Données du bûcheron ---
var wood: int = 10
const LUMBERJACK_WOOD_PER_MIN: float = 2.0
var nb_lumberjack: int = 1

# --- Simulation ---
var elapsed: float = 0.0
const REFRESH: float = 0.5
var wood_progress: float = 0.0    # ⚡ accumulation des "fractions" de bois

# --- UI ---
var row_node: Control

func _ready() -> void:
	row_node = row_scene.instantiate()
	rows_box.add_child(row_node)
	_update_row(0.0)

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= REFRESH:
		elapsed = 0.0
		_simulate(REFRESH)
		_update_row(LUMBERJACK_WOOD_PER_MIN)

func _simulate(seconds: float) -> void:
	var minutes: float = seconds / 60.0
	var produced: float = LUMBERJACK_WOOD_PER_MIN * float(nb_lumberjack) * minutes

	# On accumule les fractions dans wood_progress
	wood_progress += produced

	# Chaque fois qu'on atteint 1 unité complète, on l'ajoute au stock
	while wood_progress >= 1.0:
		wood += 1
		wood_progress -= 1.0

	if wood < 0:
		wood = 0

func _update_row(prod_rate: float) -> void:
	var prod: float = prod_rate
	var dem: float = 0.0
	var net: float = prod - dem
	row_node.set_values("Cabane de bûcheron", prod, dem, net, wood, "t/min")
