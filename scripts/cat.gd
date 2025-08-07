extends Node3D
@onready var cat_animation: AnimationPlayer = $AnimationPlayer
@onready var animation_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var cat_model: MeshInstance3D = $Muchkin1_002

var is_looping = false
var global_scene

func _ready() -> void:
	# Connect to stimulation signals
	GlobalVar.stimulation_increase.connect(_on_stimulation_changed)
	GlobalVar.stimulation_decrease.connect(_on_stimulation_changed)
	
	# Initially hide the cat
	cat_model.visible = false
	
	# Check initial stimulation state
	_on_stimulation_changed(GlobalVar.stimulation)

func _on_stimulation_changed(new_stimulation_value):
	if new_stimulation_value >= 1 and not is_looping:
		# Show cat and start animation
		cat_model.visible = true
		start_looping()
	elif new_stimulation_value < 1 and is_looping:
		# Hide cat and stop animation
		cat_model.visible = false
		stop_looping()

func start_looping():
	if is_looping:
		return  # Already looping
	
	is_looping = true
	_loop_animation()

func stop_looping():
	is_looping = false
	cat_animation.stop()
	animation_sound.stop()

func _loop_animation():
	while is_looping:
		if not is_looping:  # Check again in case it changed
			break
			
		cat_animation.play("Take 001")
		await get_tree().create_timer(1.0).timeout
		
		if not is_looping:
			break
		
		# Play the sounds 3 times
		animation_sound.play()
		var audio_length = animation_sound.stream.get_length()
		await get_tree().create_timer(audio_length - 0.25).timeout
		
		if not is_looping:
			break
			
		animation_sound.play()
		await get_tree().create_timer(audio_length - 0.25).timeout
		
		if not is_looping:
			break
			
		animation_sound.play()
		await get_tree().create_timer(audio_length).timeout
		
		if not is_looping:
			break
			
		await cat_animation.animation_finished
		await get_tree().create_timer(0.5).timeout
