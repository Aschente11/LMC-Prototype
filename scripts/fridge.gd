extends Node3D


@onready var anim_player: AnimationPlayer = $Fridge/AnimationPlayer

var is_open: bool = true

func _on_ois_directional_swipe_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if is_open:
		anim_player.play("open_fridge")
	else:
		anim_player.play("close_fridge")
	
	is_open = !is_open
