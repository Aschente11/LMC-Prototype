extends Node3D

@onready var marker: Sprite2D = $GalaxyWatch/screen/SubViewport/Control/MarginContainer/Sprite2D

func _ready() -> void:
	GlobalVar.stimulation_changed.connect(_on_stimulation_changed)

func _on_stimulation_changed(new_value: int) -> void:
	# Wait 5 seconds before changing position and rotation
	await get_tree().create_timer(4.0).timeout
	
	# Change position and rotation after delay
	marker.position.x += 30
	marker.position.y += 30
	marker.rotation += deg_to_rad(20)
