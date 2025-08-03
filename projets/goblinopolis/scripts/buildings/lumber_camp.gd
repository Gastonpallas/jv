# Buildings/LumberCamp.gd
extends Node2D

@export var production_type = "bois"
@export var production_amount = 1
@export var production_delay = 5.0
@export var ouvriers_requis = 1
@onready var jauge: Node2D = $Jauge

var timer := 0.0
var actif := false

func _ready():
	var gs = get_node("/root/Main/GameState")
	if gs.consommer_ouvriers(ouvriers_requis):
		actif = true
		jauge.delay = production_delay
		jauge.timer = timer
	else:
		print("Pas assez d’ouvriers pour activer cette cabane")

func _process(delta):
	if not actif:
		return
	timer += delta
	if timer >= production_delay:
		produire()
		timer = 0.0

func produire():
	var gs = get_node("/root/Main/GameState")
	gs.ajouter_ressource(production_type, production_amount)
	jauge.delay = production_delay
	jauge.timer = 0.0 


func peut_construire(gs) -> bool:
	return gs.get_ouvriers_disponibles() >= 1
