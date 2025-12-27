class_name FloatingIndicatorManager

extends Node3D

@export var indicator_scene := preload("res://scenes/UI/floating_indicator.tscn")

enum IndicatorType {
	PHYSICAL_GAIN,
	PHYSICAL_LOSS,
	EMOTIONAL_GAIN,
	EMOTIONAL_LOSS
}

func show_indicator(position: Vector3, text: String, color: Color = Color.SEA_GREEN):
	var indicator = indicator_scene.instantiate()
	add_child(indicator)
	
	indicator.position = position
	indicator.setup(text, color)
	
	var random_offset = Vector3(
		randf_range(-0.2, 0.2),
		randf_range(0, 0.3),
		randf_range(-0.2, 0.2)
	)
	
	indicator.position += random_offset


func show_typed_indicator(position: Vector3, type: IndicatorType, value: String = ""):
	var text = ""
	var color = Color.WHITE
	
	match type:
		IndicatorType.PHYSICAL_GAIN:
			text = "++Physical"
			color = Color.RED
		IndicatorType.PHYSICAL_LOSS:
			text = "--Physical"
			color = Color.RED
		IndicatorType.EMOTIONAL_GAIN:
			text = "++Emotional"
			color = Color.BLUE
		IndicatorType.EMOTIONAL_LOSS:
			text = "--Emotional"
			color = Color.BLUE
	
	show_indicator(position, text, color)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
