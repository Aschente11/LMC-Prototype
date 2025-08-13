extends Node3D

@onready var right_hand: XRController3D = $XROrigin3D/XRController3DRight
@onready var left_hand: XRController3D = $XROrigin3D/XRController3DLeft
@onready var watch_sfx: AudioStreamPlayer3D = $watchNotif
@onready var make_bfast_text: MeshInstance3D = $"XROrigin3D/XRCamera3D/make bfast"
@onready var need_unpack_text: MeshInstance3D = $"XROrigin3D/XRCamera3D/need to unpack"
@onready var tired_text: MeshInstance3D = $XROrigin3D/XRCamera3D/tired
@onready var left_watch: Node3D = $XROrigin3D/XRController3DLeft/smartwatch
@onready var right_watch: Node3D = $XROrigin3D/XRController3DRight/smartwatch

var watch_is_left: bool = true

func _ready() -> void:
	add_to_group("player")
	make_bfast_text.add_to_group("make_bfast_text")
	need_unpack_text.add_to_group("need_unpack_text")
	tired_text.add_to_group("tired_text")
	GlobalVar.stimulation_increase.connect(_on_stimulation_changed)
	GlobalVar.stimulation_decrease.connect(_on_stimulation_changed)

func _on_stimulation_changed(new_value: int) -> void:
	# Create a timer for 2-second delay
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(_on_delay_timeout)
	timer.start()
	
func _process(delta: float) -> void:
	if left_hand and left_hand.get_is_active() and left_hand.is_button_pressed("ax_button"):
		await left_hand.button_released
		if right_watch.visible:
			right_watch.hide()
			left_watch.show()
		else:
			left_watch.hide()
			right_watch.show()

func _on_delay_timeout() -> void:
	trigger_double_haptic_feedback()

func trigger_double_haptic_feedback() -> void:
	trigger_haptic_feedback()
	watch_sfx.play()
	await get_tree().create_timer(0.3).timeout
	trigger_haptic_feedback()


func trigger_haptic_feedback(duration: float = 0.2, frequency: float = 0.5, amplitude: float = 0.8) -> void:
	right_hand.trigger_haptic_pulse("haptic", frequency, amplitude, duration, 0.0)
