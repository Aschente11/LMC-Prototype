extends Node3D

@onready var marker: Sprite2D = $GalaxyWatch/screen/SubViewport/Control/MarginContainer/Sprite2D

func _ready() -> void:
	GlobalVar.stimulation_changed.connect(_on_stimulation_changed)

func _on_stimulation_changed(new_value: int) -> void:
	marker.position.x += 30
	marker.position.y += 30
	marker.rotation += deg_to_rad(20)
