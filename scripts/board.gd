extends Node3D 
 
@onready var text: MeshInstance3D = $text 
@onready var writing_sfx: AudioStreamPlayer3D = $AudioStreamPlayer3D 
@export var full_text: String = "Things to do today:\n  1. cook bfast\n  2. draw a house\n  3. clean my shi\n 4. sleep early" 
@export var wipes_per_letter: int = 3  # Number of wipes needed to reveal one letter 
 
var current_text: String = "" 
var letter_index: int = 0 
var is_initialized: bool = false 
var wipe_count: int = 0 
var is_actively_wiping: bool = false
var wipe_timer: Timer  # Timer to detect when wiping stops
var last_wipe_time: float = 0.0
var audio_position: float = 0.0  # Store the audio position when paused
var is_audio_paused: bool = false

func _ready(): 
	text.visible = false 
	if text.mesh is TextMesh: 
		text.mesh.text = "" 
	
	# Create timer for detecting wipe inactivity
	wipe_timer = Timer.new()
	wipe_timer.wait_time = 0.2  # Stop sound after 0.2 seconds of no wiping
	wipe_timer.one_shot = true
	wipe_timer.timeout.connect(_on_wipe_timeout)
	add_child(wipe_timer)
 
func _on_ois_wipe_receiver_action_started(requirement: Variant, total_progress: Variant) -> void: 
	text.visible = true 
	 
	# Only initialize once, don't reset if already started 
	if not is_initialized: 
		letter_index = 0 
		current_text = "" 
		wipe_count = 0 
		is_initialized = true 
	
	_handle_wipe_input()
 
func _handle_wipe_input():
	last_wipe_time = Time.get_time_dict_from_system()["hour"] * 3600 + Time.get_time_dict_from_system()["minute"] * 60 + Time.get_time_dict_from_system()["second"]
	
	# Start or resume sound if not already playing and there are still letters to reveal
	if not is_actively_wiping and letter_index < full_text.length():
		_start_writing_sound()
	
	# Reset the timer
	wipe_timer.start()
	is_actively_wiping = true
	
	_check_reveal_letter()

func _start_writing_sound():
	if writing_sfx.stream and letter_index < full_text.length():
		if is_audio_paused:
			# Resume from stored position
			_resume_writing_sound()
		elif not writing_sfx.playing:
			# Start fresh
			writing_sfx.play()
			is_audio_paused = false

func _stop_writing_sound():
	if writing_sfx.playing:
		# Store current playback position before stopping
		audio_position = writing_sfx.get_playback_position()
		writing_sfx.stop()
		is_audio_paused = true

func _resume_writing_sound():
	if writing_sfx.stream and is_audio_paused:
		# Play from stored position
		writing_sfx.play(audio_position)
		is_audio_paused = false

func _on_wipe_timeout():
	# Called when wiping stops (no input for 0.2 seconds)
	is_actively_wiping = false
	_stop_writing_sound()
 
func _check_reveal_letter(): 
	wipe_count += 1 
	if wipe_count >= wipes_per_letter: 
		_reveal_next_letter() 
		wipe_count = 0  # Reset counter after revealing letter 
 
func _reveal_next_letter(): 
	if letter_index < full_text.length(): 
		current_text += full_text[letter_index] 
		text.mesh.text = current_text 
		letter_index += 1 
		
		# If we've revealed all letters, stop the sound completely
		if letter_index >= full_text.length():
			writing_sfx.stop()
			is_audio_paused = false
			audio_position = 0.0
 
func _on_ois_wipe_receiver_action_in_progress(requirement: Variant, total_progress: Variant) -> void: 
	_handle_wipe_input()
 
func _on_ois_wipe_receiver_action_completed(requirement: Variant, total_progress: Variant) -> void: 
	# Stop wiping activity
	is_actively_wiping = false
	_stop_writing_sound()
	
	# Optional: reveal final letter when completed 
	pass
