extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var opening_sfx = $opening_sfx
@onready var closing_sfx = $closing_sfx

var door_is_open = false

func _on_ois_directional_swipe_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if door_is_open:
		anim_player.play("closing_door")
		closing_sfx.play()
		door_is_open = false
	else:
		anim_player.play('opening_door')
		opening_sfx.play()
		door_is_open = true
