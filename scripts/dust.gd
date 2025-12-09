extends Node3D

func _on_ois_wipe_receiver_action_in_progress(requirement: Variant, total_progress: Variant) -> void:
	GlobalVar.add_dust_cleaned()  # This updates the GLOBAL counter
	queue_free()
