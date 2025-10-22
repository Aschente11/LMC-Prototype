extends StaticBody3D

@onready var keyboard_sfx = $"keyboard sfx"
var saved_position: float = 0.0

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	# Resume from saved position
	keyboard_sfx.play()
	keyboard_sfx.seek(saved_position)
	
	# Tell the typing animation to start
	TypingManager.start_typing()

func _on_ois_strike_receiver_action_ended(requirement: Variant, total_progress: Variant) -> void:
	# Save current position before stopping
	saved_position = keyboard_sfx.get_playback_position()
	keyboard_sfx.stop()
	
	# Tell the typing animation to stop
	TypingManager.stop_typing()
