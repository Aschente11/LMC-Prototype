extends Node3D

@onready var staticbody = $StaticBody3D

func _ready() -> void:
	staticbody.add_to_group("cupboard")
