extends Control

@onready var spawn_point = $SpawnPoint
@onready var indicator_number_template = preload("res://scenes/UI/indicator_numbers.tscn")
@export var spread_value: float
@export var height_value: float

var indicator_number_pool: Array[IndicatorNumbers] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func spawn_indicator(value: String):
	var indicator = get_indicator()
	var pos = spawn_point.position
	var height = height_value
	var spread = spread_value
	add_child(indicator, true)
	indicator.set_values_and_animate(value, pos, height, spread)
	
func get_indicator() -> IndicatorNumbers:
	if indicator_number_pool.size() > 0:
		return indicator_number_pool.pop_front()
	else:
		var new_indicator_number = indicator_number_template.instantiate()
		new_indicator_number.tree_exiting.connect(
			func():indicator_number_pool.append(new_indicator_number)
		)
		return new_indicator_number
