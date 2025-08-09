extends Node3D
@onready var cat_animation: AnimationPlayer = $AnimationPlayer
@onready var animation_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var cat_model: MeshInstance3D = $Muchkin1_002

var is_looping = false

func _ready() -> void:
	GlobalVar.stimulation_increase.connect(_on_stimulation_increase)
	GlobalVar.stimulation_decrease.connect(_on_stimulation_decrease)
	
	
	cat_model.visible = false
	
	# Check initial stimulation state with a small delay to ensure everything is ready
	call_deferred("check_initial_state")


func check_initial_state() -> void:
	_on_stimulation_changed(GlobalVar.stimulation)

# Connect to the same signals as the smartwatch for consistency
func _on_stimulation_increase(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_decrease(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_changed(new_stimulation_value: int) -> void:
	
	if new_stimulation_value >= 1 and not is_looping:
		# Show cat and start animation
		cat_model.visible = true
		start_looping()
	elif new_stimulation_value < 1 and is_looping:
		# Hide cat and stop animation
		cat_model.visible = false
		stop_looping()

func start_looping() -> void:
	if is_looping:
		return  # Already looping
	
	is_looping = true
	_loop_animation()

func stop_looping() -> void:
	is_looping = false
	cat_animation.stop()
	animation_sound.stop()

func _loop_animation() -> void:
	
	while is_looping:
		# Play animation
		cat_animation.play("Take 001")
		await get_tree().create_timer(1.0).timeout
		
		if not is_looping:
			break
		
		# Play the sounds 3 times
		for i in range(3):
			if not is_looping:
				break
				
			animation_sound.play()
			var audio_length = animation_sound.stream.get_length()
			var wait_time = audio_length - 0.25 if i < 2 else audio_length
			await get_tree().create_timer(wait_time).timeout
		
		if not is_looping:
			break
		
		# Wait for animation to finish
		await cat_animation.animation_finished
		
		if not is_looping:
			break
			
		await get_tree().create_timer(0.5).timeout

# Minimal poof effect - just add this to your existing code
func appear_with_poof() -> void:
	cat_model.visible = true
	cat_model.scale = Vector3.ZERO
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(cat_model, "scale", Vector3.ONE, 0.6)
	
	await tween.finished
	start_looping()
