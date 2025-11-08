extends HBoxContainer
class_name RessourceRow 

@onready var name_lbl: Label = $Name
@onready var prod_lbl: Label = $Prod
@onready var dem_lbl: Label = $Dem
@onready var balance_lbl: Label = $Balance
@onready var qty_lbl: Label = $Qty


func set_values(
	name_text: String,
	prod: float,
	dem: float,
	balance: float,
	qty_value: int
) -> void:
	name_lbl.text = name_text
	prod_lbl.text = _format_number(prod)
	dem_lbl.text  = _format_number(dem)
	balance_lbl.text = _format_number(balance)
	qty_lbl.text  = str(qty_value)

func _format_number(value: float) -> String:
	return str(int(value)) if value == floor(value) else "%.2f" % value

func set_quantity(qty_value: int) -> void:
	qty_lbl.text = str(qty_value)
	
func set_prod(v: float) -> void: prod_lbl.text = str(v)
func set_dem(v: float) -> void:  dem_lbl.text  = str(v)
func set_balance(v: float) -> void: balance_lbl.text = str(v)
