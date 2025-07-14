extends Node3D

@onready var marker: Sprite2D = $GalaxyWatch/screen/SubViewport/Control/MarginContainer/Sprite2D

func _ready() -> void:
	GlobalVar.stimulation_increase.connect(_on_stimulation_increase)
	GlobalVar.stimulation_decrease.connect(_on_stimulation_decrease)

func _on_stimulation_increase(new_value: int) -> void:
	await get_tree().create_timer(4.0).timeout
	
	marker.position.x += 30
	marker.position.y += 30
	marker.rotation += deg_to_rad(20)

func _on_stimulation_decrease(new_value: int) -> void:
	await get_tree().create_timer(4.0).timeout
	
	marker.position.x -= 30
	marker.position.y -= 30
	marker.rotation -= deg_to_rad(20)
