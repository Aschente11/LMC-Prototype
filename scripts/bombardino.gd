extends Node3D

@onready var tralalero_mesh: MeshInstance3D = $tralalero
@onready var tralalero_audio: AudioStreamPlayer3D = $tralalero/tralalero

@onready var bombardino_mesh: MeshInstance3D = $bombardino
@onready var bombardino_audio: AudioStreamPlayer3D = $bombardino/bombardino

@onready var tung_mesh: MeshInstance3D = $"tung tung"
@onready var tung_audio: AudioStreamPlayer3D = $"tung tung/tung tung"

# Array to store mesh/audio pairs for easy management
var mesh_audio_pairs: Array = []
var remaining_meshes: Array = []
var player_camera: XRCamera3D = null  # Reference to XR camera
var player_position: Vector3 = Vector3.ZERO  # Player position (center of room)

# Current playing audio reference
var current_audio: AudioStreamPlayer3D = null
var audio_check_timer: Timer

# Looping control
var is_looping: bool = false
var should_be_looping: bool = false

# Configuration
@export var spawn_radius: float = 2.0  # Distance from player to spawn meshes (reduced for visibility)
@export var spawn_height_offset: float = 0.0  # Height offset from player
@export var min_spawn_distance: float = 1.0  # Minimum distance to ensure visibility
@export var max_spawn_distance: float = 2.0  # Maximum distance to keep meshes close
@export var auto_start: bool = true
@export var loop_sequence: bool = true  # Whether to repeat the sequence
@export var auto_find_player: bool = true  # Automatically find XR player

func _ready() -> void:
	# Initialize mesh/audio pairs
	mesh_audio_pairs = [
		{"mesh": tralalero_mesh, "audio": tralalero_audio},
		{"mesh": bombardino_mesh, "audio": bombardino_audio},
		{"mesh": tung_mesh, "audio": tung_audio},
	]
	
	# Hide all meshes initially
	hide_all_meshes()
	
	# Try to find XR player camera automatically
	if auto_find_player:
		find_xr_player()
	
	# Setup audio check timer
	setup_audio_check_timer()
	
	# Connect stimulation signals
	GlobalVar.stimulation_increase.connect(_on_stimulation_increase)
	GlobalVar.stimulation_decrease.connect(_on_stimulation_decrease)
	
	# Check initial stimulation state with a small delay to ensure everything is ready
	call_deferred("check_initial_state")
	
func check_initial_state() -> void:
	_on_stimulation_changed(GlobalVar.stimulation)
	
func _on_stimulation_increase(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_decrease(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_changed(new_stimulation_value: int) -> void:
	print("Stimulation changed to: ", new_stimulation_value)
	
	if new_stimulation_value >= 2 and not is_looping:
		start_looping()
	elif new_stimulation_value < 2 and is_looping:
		stop_looping()

func start_looping() -> void:
	print("Starting distraction loop")
	is_looping = true
	should_be_looping = true
	loop_sequence = true
	start_distraction_sequence()

func stop_looping() -> void:
	print("Stopping distraction loop")
	is_looping = false
	should_be_looping = false
	loop_sequence = false
	stop_sequence()

func hide_all_meshes() -> void:
	for pair in mesh_audio_pairs:
		pair.mesh.visible = false

func find_xr_player() -> void:
	# Search for XRCamera3D in the scene tree
	var scene_root = get_tree().current_scene
	player_camera = find_node_of_type(scene_root, "XRCamera3D")
	
	if player_camera:
		print("Found XR Camera: ", player_camera.name)
	else:
		print("XR Camera not found - using default position Vector3.ZERO")

func find_node_of_type(node: Node, type_name: String) -> Node:
	if node.get_class() == type_name:
		return node
	
	for child in node.get_children():
		var result = find_node_of_type(child, type_name)
		if result:
			return result
	
	return null

func setup_audio_check_timer() -> void:
	audio_check_timer = Timer.new()
	add_child(audio_check_timer)
	audio_check_timer.wait_time = 0.1  # Check every 0.1 seconds
	audio_check_timer.timeout.connect(_on_audio_check_timeout)

func start_distraction_sequence() -> void:
	# Only start if we should be looping
	if not should_be_looping:
		return
	
	# Reset the sequence
	remaining_meshes = mesh_audio_pairs.duplicate()
	hide_all_meshes()
	current_audio = null
	
	# Show the first mesh immediately
	if remaining_meshes.size() > 0:
		show_next_mesh()

func _on_audio_check_timeout() -> void:
	# Check if we should still be looping
	if not should_be_looping:
		audio_check_timer.stop()
		return
	
	# Check if current audio is still playing
	if current_audio == null or not current_audio.playing:
		# Audio finished, show next mesh if available
		if remaining_meshes.size() > 0:
			show_next_mesh()
		elif loop_sequence and should_be_looping:
			# Restart the sequence if looping is enabled and we should still be looping
			start_distraction_sequence()
		else:
			# Stop checking if not looping
			audio_check_timer.stop()

func show_next_mesh() -> void:
	# Check if we should still be looping
	if not should_be_looping:
		return
	
	if remaining_meshes.size() > 0:
		# Update player position from camera if available
		update_player_position_from_camera()
		
		# Hide all meshes first to ensure only one is visible
		hide_all_meshes()
		
		# Pick a random mesh from remaining ones
		var random_index = randi() % remaining_meshes.size()
		var selected_pair = remaining_meshes[random_index]
		
		# Position mesh around player and show it
		position_mesh_around_player(selected_pair.mesh)
		show_mesh_and_play_audio(selected_pair)
		
		# Remove from remaining meshes
		remaining_meshes.remove_at(random_index)
		
		# Start checking for audio completion
		if not audio_check_timer.is_stopped():
			audio_check_timer.stop()
		audio_check_timer.start()

func update_player_position_from_camera() -> void:
	if player_camera:
		player_position = player_camera.global_position
		print("Updated player position to: ", player_position)

func show_mesh_and_play_audio(pair: Dictionary) -> void:
	var mesh: MeshInstance3D = pair.mesh
	var audio: AudioStreamPlayer3D = pair.audio
	
	# Show the mesh
	mesh.visible = true
	
	# Make the mesh face the player
	face_player(mesh)
	
	# Play the corresponding audio and store reference
	if audio and audio.stream:
		current_audio = audio
		audio.play()

func position_mesh_around_player(mesh: MeshInstance3D) -> void:
	# Generate a random angle around the player (0 to 360 degrees)
	var angle = randf() * 2 * PI
	
	# Generate a random distance within the specified range
	var distance = randf_range(min_spawn_distance, max_spawn_distance)
	
	# Calculate position around the player
	var offset_x = cos(angle) * distance
	var offset_z = sin(angle) * distance
	var spawn_position = player_position + Vector3(offset_x, spawn_height_offset, offset_z)
	
	# Set mesh position
	mesh.global_position = spawn_position
	print("Positioned mesh '", mesh.name, "' at: ", spawn_position, " (distance: ", distance, ", player at: ", player_position, ")")

func face_player(mesh: MeshInstance3D) -> void:
	# Calculate direction from mesh to player
	var direction = (player_position - mesh.global_position).normalized()
	
	# Only rotate on Y axis to face player (assuming meshes should stay upright)
	var target_rotation = Vector3(0, atan2(direction.x, direction.z), 0)
	mesh.rotation = target_rotation

# Public functions to control the system
func reset_distraction() -> void:
	audio_check_timer.stop()
	current_audio = null
	hide_all_meshes()

func start_new_sequence() -> void:
	if should_be_looping:
		start_distraction_sequence()

func stop_sequence() -> void:
	audio_check_timer.stop()
	if current_audio:
		current_audio.stop()
	current_audio = null
	hide_all_meshes()

# Call this function to update player position if it changes
func update_player_position(new_position: Vector3) -> void:
	player_position = new_position

# Manually set the XR Camera reference
func set_player_camera(camera: XRCamera3D) -> void:
	player_camera = camera
	if player_camera:
		update_player_position_from_camera()

# Toggle looping on/off
func set_looping(enabled: bool) -> void:
	loop_sequence = enabled

# Optional: Call this to manually trigger a specific mesh
func show_specific_mesh(mesh_name: String) -> void:
	for pair in mesh_audio_pairs:
		var mesh_node_name = pair.mesh.name
		if mesh_node_name == mesh_name:
			show_mesh_and_play_audio(pair)
			break
