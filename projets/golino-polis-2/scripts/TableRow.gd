extends HBoxContainer

@onready var l_name = $Name
@onready var l_prod = $Prod
@onready var l_dem  = $Dem
@onready var l_net  = $Net
@onready var l_qty  = $Qty


func set_values(name:String, prod:float, dem:float, net:float, qty:float, unit:String)->void:
	l_name.text = name
	l_prod.text = "%0.2f %s" % [prod, unit]
	l_dem.text  = "%0.2f %s" % [dem,  unit]
	l_net.text  = "%0.2f %s" % [net,  unit]
	l_qty.text  = "%0.1f" % qty
	var c := Color.WHITE
	if net > 0.001: c = Color(0.2, 0.8, 0.2)
	elif net < -0.001: c = Color(0.9, 0.3, 0.3)
	l_net.add_theme_color_override("font_color", c)
