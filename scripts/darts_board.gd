extends Node3D
@onready var darts = $XRToolsPickable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	darts.add_to_group("darts")
