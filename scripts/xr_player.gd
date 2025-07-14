extends Node3D

@onready var right_hand: XRController3D = $XROrigin3D/XRController3DRight
@onready var left_hand: XRController3D = $XROrigin3D/XRController3DLeft
@onready var watch_sfx: AudioStreamPlayer3D = $watchNotif

func _ready() -> void:
	add_to_group("player")
	GlobalVar.stimulation_changed.connect(_on_stimulation_changed)

func _on_stimulation_changed(new_value: int) -> void:
	# Create a timer for 2-second delay
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(_on_delay_timeout)
	timer.start()

func _on_delay_timeout() -> void:
	trigger_double_haptic_feedback()

func trigger_double_haptic_feedback() -> void:
	trigger_haptic_feedback()
	watch_sfx.play()
	await get_tree().create_timer(0.3).timeout
	trigger_haptic_feedback()


func trigger_haptic_feedback(duration: float = 0.2, frequency: float = 0.5, amplitude: float = 0.8) -> void:
	right_hand.trigger_haptic_pulse("haptic", frequency, amplitude, duration, 0.0)
