extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var opening_sfx = $opening_sfx
@onready var closing_sfx = $closing_sfx
@onready var timer_ring = $SubViewport/TimerRing

var door_is_open = false
var countdown_seconds: float = 30.0

func _ready():
	await get_tree().process_frame
	if timer_ring:
		timer_ring.countdown_finished.connect(_on_countdown_finished)


func _on_countdown_finished():
	GlobalVar.decrease_physical()
	GlobalVar.decrease_emotional()
	turn_off_device()

func turn_off_device():
	timer_ring.hide_timer()

func set_countdown_duration(seconds: float):
	countdown_seconds = seconds

func get_remaining_time() -> float:
	if timer_ring:
		return timer_ring.get_remaining_time()
	return 0.0


func _on_ois_directional_swipe_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if door_is_open:
		anim_player.play("closing_door")
		closing_sfx.play()
		door_is_open = false
	else:
		anim_player.play('opening_door')
		opening_sfx.play()
		door_is_open = true

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	timer_ring.start_countdown(countdown_seconds)
