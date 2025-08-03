extends Node2D


func _ready():
	var gs = get_node("/root/Main/GameState")
	gs.ajouter_ressource("bois", 5)
