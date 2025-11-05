extends Node3D

@onready var animation_player = $"../AnimationPlayer"
@onready var spinner_node = $".."
@onready var audio = $"../AudioStreamPlayer3D"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ois_strike_receiver_action_started(requirement, total_progress):
	if spinner_node.is_picked_up():
		if not audio.playing:
			animation_player.play("spinny")
		audio.play()


func _on_ois_strike_receiver_action_ended(requirement, total_progress):
	animation_player.pause()
	audio.stop()
