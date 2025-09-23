extends Node3D

@onready var finished_sfx = $finished_sfx

func _ready() -> void:
	finished_sfx.play()
