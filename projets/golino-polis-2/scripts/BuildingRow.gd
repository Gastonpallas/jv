extends HBoxContainer

class_name BuildingRow

@onready var name_lbl: Label = $Name
@onready var prod_lbl: Label = $Prod
@onready var dem_lbl: Label = $Dem
@onready var cost_lbl: Label = $Cost
@onready var qty_lbl: Label = $Qty
@export var building_id := ""

signal add_pressed(building_id: String)

func set_values(
	name_text: String,
	prod: float, prod_unit: String,
	dem: float, dem_unit: String,
	cost: float, cost_unit: String,
	qty_value: int
) -> void:
	name_lbl.text = name_text
	prod_lbl.text = "%s %s" % [_format_number(prod), prod_unit]
	dem_lbl.text  = "%s %s" % [_format_number(dem),  dem_unit]
	cost_lbl.text = "%s %s" % [_format_number(cost), cost_unit]
	qty_lbl.text  = str(qty_value)

func _format_number(value: float) -> String:
	return str(int(value)) if value == floor(value) else "%.2f" % value

func set_quantity(qty_value: int) -> void:
	qty_lbl.text = str(qty_value)




func _on_subtract_pressed() -> void:
	pass # Replace with function body.


func _on_add_pressed() -> void:
	emit_signal("add_pressed", building_id) 
	
	
	
	
