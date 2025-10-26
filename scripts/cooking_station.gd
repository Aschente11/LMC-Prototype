extends Node3D
@onready var fire = $Fire
@onready var stove_sfx = $stove

var stove_is_open = false

func _ready() -> void:
	fire.visible = false

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if stove_is_open:
		fire.visible = false
		stove_is_open = false
	else:
		stove_sfx.play()
		fire.visible = true
		stove_is_open = true
