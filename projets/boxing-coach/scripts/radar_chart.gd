extends Node2D

const MAX_VALUE = 100
const RADIUS = 80
const STAT_COUNT = 5
const WEB_LAYERS = 4  # nombre de cercles intermédiaires

@onready var stat_polygon := Polygon2D.new()
@onready var web_polygon := Node2D.new()  # contiendra les lignes guides

var stats = {
	"strength": 0,
	"stamina": 0,
	"hp": 0,
	"speed": 0,
	"technic": 0
}

var stat_labels = [
	"💪 STR",
	"♻️ STA",
	"❤️ HP",
	"⚡ SPD",
	"🧠 TEC"
]


func _ready():
	add_child(web_polygon)
	add_child(stat_polygon)
	draw_web()
	draw_chart()

func set_stats(new_stats: Dictionary):
	stats = new_stats
	draw_chart()

func draw_chart():
	var values = [
		stats.get("strength", 0),
		stats.get("stamina", 0),
		stats.get("hp", 0),
		stats.get("speed", 0),
		stats.get("technic", 0)
	]

	var angle_step = TAU / STAT_COUNT
	var points = []

	for i in range(STAT_COUNT):
		var angle = angle_step * i - PI / 2
		var ratio = clamp(float(values[i]) / MAX_VALUE, 0, 1)
		var x = cos(angle) * RADIUS * ratio
		var y = sin(angle) * RADIUS * ratio
		points.append(Vector2(x, y))

	stat_polygon.polygon = points
	stat_polygon.color = Color("#44CCFFAA")  # semi-transparent bleu

func draw_web():
	web_polygon.queue_free()
	web_polygon = Node2D.new()
	add_child(web_polygon)

	var angle_step = TAU / STAT_COUNT

	# cercles concentriques
	for layer in range(1, WEB_LAYERS + 1):
		var ring = Polygon2D.new()
		var points = []
		var ratio = float(layer) / WEB_LAYERS
		for i in range(STAT_COUNT):
			var angle = angle_step * i - PI / 2
			var x = cos(angle) * RADIUS * ratio
			var y = sin(angle) * RADIUS * ratio
			points.append(Vector2(x, y))
		ring.polygon = points
		ring.color = Color(0.8, 0.8, 0.8, 0.2)  # gris clair transparent
		web_polygon.add_child(ring)

	# lignes radiales
	for i in range(STAT_COUNT):
		var angle = angle_step * i - PI / 2
		var line = Line2D.new()
		line.width = 1
		line.default_color = Color(0.8, 0.8, 0.8, 0.5)
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2(cos(angle), sin(angle)) * RADIUS)
		web_polygon.add_child(line)
		
		# Ajout des labels aux extrémités
	for i in range(STAT_COUNT):
		var angle = angle_step * i - PI / 2
		var pos = Vector2(cos(angle), sin(angle)) * (RADIUS + 30)
		
		var label = Label.new()
		label.text = stat_labels[i]
		label.modulate = Color(0.9, 0.9, 0.9)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.position = pos - Vector2(label.size.x / 2, label.size.y / 2)

		web_polygon.add_child(label)
