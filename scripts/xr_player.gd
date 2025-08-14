extends Node3D
@onready var right_hand: XRController3D = $XROrigin3D/XRController3DRight
@onready var left_hand: XRController3D = $XROrigin3D/XRController3DLeft
@onready var watch_sfx: AudioStreamPlayer3D = $watchNotif
@onready var make_bfast_text: MeshInstance3D = $"XROrigin3D/XRCamera3D/make bfast"
@onready var need_unpack_text: MeshInstance3D = $"XROrigin3D/XRCamera3D/need to unpack"
@onready var tired_text: MeshInstance3D = $XROrigin3D/XRCamera3D/tired

var random_thoughts = preload("res://scenes/distractions/Random_thoughts.tscn")
var brainrot_thoughts = preload("res://scenes/distractions/Brainrot_thoughts.tscn")

# New variables for thought management
var thought_spawn_timer: Timer
var active_thoughts: Array[Node] = []
var is_spawning_thoughts: bool = false

func _ready() -> void:
	add_to_group("player")
	make_bfast_text.add_to_group("make_bfast_text")
	need_unpack_text.add_to_group("need_unpack_text")
	tired_text.add_to_group("tired_text")
	
	# Setup the thought spawning timer
	setup_thought_timer()
	
	# Debug: Print current stimulation level
	print("Current stimulation level: ", GlobalVar.stimulation)
	
	# Connect to stimulation signals
	if GlobalVar.stimulation_increase.connect(_on_stimulation_changed) != OK:
		print("Failed to connect stimulation_increase signal")
	if GlobalVar.stimulation_decrease.connect(_on_stimulation_changed) != OK:
		print("Failed to connect stimulation_decrease signal")
	
	# Check initial stimulation level and start spawning if needed
	if GlobalVar.stimulation >= 2:
		print("Initial stimulation level is >= 2, starting thought spawning")
		start_spawning_thoughts()

func setup_thought_timer() -> void:
	thought_spawn_timer = Timer.new()
	add_child(thought_spawn_timer)
	thought_spawn_timer.wait_time = 3.0
	thought_spawn_timer.timeout.connect(_on_spawn_thought)
	# Don't start the timer yet - it will start when stimulation reaches 2

func _on_stimulation_changed(new_value: int) -> void:
	print("Stimulation changed to: ", new_value)  # Debug print
	
	# Handle thought spawning based on stimulation level
	if new_value >= 2 and not is_spawning_thoughts:
		print("Starting to spawn thoughts")  # Debug print
		start_spawning_thoughts()
	elif new_value < 2 and is_spawning_thoughts:
		print("Stopping thought spawning")  # Debug print
		stop_spawning_thoughts()
	
	# Your existing haptic feedback logic
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(_on_delay_timeout)
	timer.start()

func start_spawning_thoughts() -> void:
	is_spawning_thoughts = true
	thought_spawn_timer.start()
	# Spawn the first thought immediately
	_on_spawn_thought()

func stop_spawning_thoughts() -> void:
	is_spawning_thoughts = false
	thought_spawn_timer.stop()
	remove_all_thoughts()

func _on_spawn_thought() -> void:
	print("Attempting to spawn thought")  # Debug print
	
	# Check if we have valid scene resources
	if not random_thoughts or not brainrot_thoughts:
		print("Error: Thought scenes not loaded properly")
		return
	
	# Randomly choose between random_thoughts and brainrot_thoughts
	var thought_scene: PackedScene
	if randi() % 2 == 0:
		thought_scene = random_thoughts
		print("Spawning random thought")
	else:
		thought_scene = brainrot_thoughts
		print("Spawning brainrot thought")
	
	# Instantiate the thought
	var thought_instance = thought_scene.instantiate()
	
	if not thought_instance:
		print("Error: Failed to instantiate thought scene")
		return
	
	# Add to the scene
	add_child(thought_instance)
	
	# Get the XR camera (player head) position
	var camera = $XROrigin3D/XRCamera3D
	var player_pos = camera.global_position
	var player_forward = -camera.global_transform.basis.z
	
	# Position the thought in front of and around the player
	var spawn_distance = randf_range(1.5, 3.0)  # Distance from player
	var angle_offset = randf_range(-PI/3, PI/3)  # Random angle (-60 to +60 degrees)
	var height_offset = randf_range(-0.5, 1.0)   # Height variation
	
	# Calculate spawn position
	var spawn_direction = player_forward.rotated(Vector3.UP, angle_offset)
	var spawn_pos = player_pos + spawn_direction * spawn_distance
	spawn_pos.y += height_offset
	
	# Set the thought position
	thought_instance.global_position = spawn_pos
	
	# Optional: Make the thought face the player
	thought_instance.look_at(player_pos, Vector3.UP)
	
	# Keep track of active thoughts
	active_thoughts.append(thought_instance)
	
	print("Thought spawned at position: ", spawn_pos)
	print("Thought spawned successfully. Active thoughts: ", active_thoughts.size())

func remove_all_thoughts() -> void:
	print("Removing all thoughts. Count: ", active_thoughts.size())
	
	# Remove all active thought instances
	for thought in active_thoughts:
		if is_instance_valid(thought):
			thought.queue_free()
	
	# Clear the array
	active_thoughts.clear()

func _on_delay_timeout() -> void:
	trigger_double_haptic_feedback()

func trigger_double_haptic_feedback() -> void:
	trigger_haptic_feedback()
	watch_sfx.play()
	await get_tree().create_timer(0.3).timeout
	trigger_haptic_feedback()

func trigger_haptic_feedback(duration: float = 0.2, frequency: float = 0.5, amplitude: float = 0.8) -> void:
	right_hand.trigger_haptic_pulse("haptic", frequency, amplitude, duration, 0.0)

# Debug function - you can call this to manually test thought spawning
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space key by default
		print("Manual thought spawn test")
		_on_spawn_thought()
