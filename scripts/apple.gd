extends Node3D


@onready var anim_player: AnimationPlayer = $Apple/AnimationPlayer
@onready var sound_effect: AudioStreamPlayer3D = $sfx


var is_cut = 0

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if is_cut == 0:
		anim_player.play("apple_slice")
		sound_effect.play()
		is_cut += 1
	GlobalVar.increase_stimulation()
	
