extends StaticBody3D

signal left_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_ois_strike_receiver_action_in_progress(requirement: Variant, total_progress: Variant) -> void:
	$AnimationPlayer.play("press")
	$AudioStreamPlayer3D.play()
	left_button_pressed.emit()
