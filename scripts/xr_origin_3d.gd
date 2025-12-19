extends XROrigin3D

@onready var change_indicator: Material = $XRCamera3D/ChangeIndicator.get_active_material(0)
@onready var sound_distraction1 = $SoundDistraction
@onready var sound_distraction2 = $SoundDistraction2
@onready var sound_distraction3 = $SoundDistraction3

var distraction_running = false


# Text configuration class
class TextConfig:
	var text: String
	var audio: AudioStreamPlayer3D
	var mesh_template: MeshInstance3D
	var spawn_weight: float  # Probability weight for random selection
	
	func _init(p_text: String, p_audio: AudioStreamPlayer3D, p_mesh: MeshInstance3D, p_weight: float = 1.0):
		text = p_text
		audio = p_audio
		mesh_template = p_mesh
		spawn_weight = p_weight

# Text system variables
var text_configs: Array[TextConfig] = []
var text_spawn_timer: Timer
var active_text_instances: Array[Node] = []
var is_spawning_texts: bool = false

# Customizable settings
var spawn_interval: float = 3  # How often new texts appear
var display_duration: float = 2.0  # How long texts stay visible after fully typed
var typewriter_speed: float = 0.04  # Time between each letter
var spawn_range: Vector3 = Vector3(2.0, 1.5, 3.0)  # x_range, y_range, z_distance
@onready var left_watch: Node3D = $XROrigin3D/XRController3DLeft/smartwatch
@onready var right_watch: Node3D = $XROrigin3D/XRController3DRight/smartwatch

var watch_is_left: bool = true

func _ready() -> void:
	add_to_group("player")
	
	$XRCamera3D/ChangeIndicator.visible = true
	# Setup text configurations
	setup_text_configs()
	
	# Setup timer
	setup_text_spawn_timer()
	
	# Debug: Print current stimulation level
	print("Current stimulation level: ", GlobalVar.stimulation)
	
	# Connect to stimulation signals
	GlobalVar.stimulation_increase.connect(trigger_indicator)
	GlobalVar.stimulation_decrease.connect(trigger_indicator)
	GlobalVar.physical_increase.connect(_on_physical_increase)
	GlobalVar.physical_decrease.connect(_on_physical_decrease)
	GlobalVar.emotional_increase.connect(_on_emotional_increase)
	GlobalVar.emotional_decrease.connect(_on_emotional_decrease)
	
	# Check initial stimulation level
	call_deferred("check_initial_state")
	# Check initial stimulation level and start spawning if needed
	

func setup_text_configs() -> void:
	# Add your text configurations here - easy to add new ones!
	text_configs.append(TextConfig.new(
		"Did I forget something?", 
		$"XROrigin3D/XRCamera3D/overthinkings/Did I forget smthn/forget audio",
		$"XROrigin3D/XRCamera3D/overthinkings/Did I forget smthn",
		1.0  # Normal spawn weight
	))
	
	# Add your new text - just add the audio node to your scene first
	text_configs.append(TextConfig.new(
		"What is life even about?",
		$"XROrigin3D/XRCamera3D/overthinkings/What is life/What is life",  # You'll need to add this audio node
		$"XROrigin3D/XRCamera3D/overthinkings/What is life",  # You'll need to add this mesh node
		0.8  # Slightly less common than the first text
	))
	
	# Hide all template texts initially
	for config in text_configs:
		if config.mesh_template:
			config.mesh_template.visible = false

func setup_text_spawn_timer() -> void:
	text_spawn_timer = Timer.new()
	add_child(text_spawn_timer)
	text_spawn_timer.wait_time = spawn_interval
	text_spawn_timer.timeout.connect(_on_text_spawn_timer_timeout)

# Combine positive and negative indicators + call indicator spawner
func trigger_indicator(old_value: int, new_value: int) -> void:
	$XRCamera3D/ChangeIndicator.visible = true
	
	if new_value == 1 or new_value == 5:
		change_indicator.set_shader_parameter("color", Color(0, 0, 0, 255))
		change_indicator.set_shader_parameter("transparency_level", 12.06)
		change_indicator.set_shader_parameter("speed", 2.01)
		change_indicator.set_shader_parameter("zoom_amplitude", 11.5)
		_on_stimulation_changed(old_value, new_value)
		return
	
	# Stimulation must change before vignette goes away
	change_indicator.set_shader_parameter("transparency_level", 13.0)
	change_indicator.set_shader_parameter("speed", 0.0)
	change_indicator.set_shader_parameter("zoom_amplitude", 12.555)
	change_indicator.set_shader_parameter("color", Color(0, 0, 0, 0))
	await get_tree().create_timer(1.0).timeout
	
	if old_value > new_value: # if decreased, blue
		change_indicator.set_shader_parameter("color", Color(0, 0, 255, 255))
		change_indicator.set_shader_parameter("speed", 1.0)
	elif old_value < new_value: # if increased, orange
		change_indicator.set_shader_parameter("color", Color(255, 100, 0, 255))
		change_indicator.set_shader_parameter("speed", 4.0)
		
	#indicators.spawn_indicator("s", str(new_value))
	
	_on_stimulation_changed(old_value, new_value)
	await get_tree().create_timer(4.0).timeout
	change_indicator.set_shader_parameter("speed", 0.0)
	change_indicator.set_shader_parameter("color", Color(0, 0, 0, 0))
	$XRCamera3D/ChangeIndicator.visible = false
	
func _on_stimulation_changed(old_value: int, new_value: int) -> void:
	print("Stimulation changed to: ", new_value)

	if new_value != 3 and not is_spawning_texts:
		start_text_spawning()
	elif new_value == 3 and is_spawning_texts:
		stop_text_spawning()
		
	if new_value >= 4:
		if not distraction_running:
			distraction_running = true
			play_distraction_loop()  # async loop
	else:
		if distraction_running:
			distraction_running = false
			sound_distraction1.stop()

	if new_value == 5:
		disable_teleport()

	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(_on_delay_timeout)
	timer.start()


func start_text_spawning() -> void:
	is_spawning_texts = true
	text_spawn_timer.start()
	# Spawn the first text immediately
	spawn_random_text()

func stop_text_spawning() -> void:
	is_spawning_texts = false
	text_spawn_timer.stop()
	cleanup_all_text_instances()

func _on_text_spawn_timer_timeout() -> void:
	if is_spawning_texts:
		spawn_random_text()

func spawn_random_text() -> void:
	if text_configs.is_empty():
		print("No text configurations available")
		return
	
	# Select random text based on weights
	var selected_config = select_weighted_random_text()
	if not selected_config:
		return
	
	# Create and show the text
	var text_instance = create_text_instance(selected_config)
	if text_instance:
		show_text_instance(text_instance, selected_config)

func select_weighted_random_text() -> TextConfig:
	# Calculate total weight
	var total_weight = 0.0
	for config in text_configs:
		total_weight += config.spawn_weight
	
	# Random selection based on weight
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for config in text_configs:
		current_weight += config.spawn_weight
		if random_value <= current_weight:
			return config
	
	# Fallback to first config
	return text_configs[0]

func create_text_instance(config: TextConfig) -> MeshInstance3D:
	var new_instance = MeshInstance3D.new()
	
	# Copy mesh and material from template
	if config.mesh_template and config.mesh_template.mesh:
		new_instance.mesh = config.mesh_template.mesh.duplicate()
	if config.mesh_template and config.mesh_template.material_override:
		new_instance.material_override = config.mesh_template.material_override
	
	# Add to scene
	$XRCamera3D.add_child(new_instance)
	new_instance.visible = false
	
	# Track instance
	active_text_instances.append(new_instance)
	
	return new_instance

func show_text_instance(text_instance: MeshInstance3D, config: TextConfig) -> void:
	if not is_instance_valid(text_instance):
		return
		
	# Position randomly
	position_text_randomly(text_instance)
	
	# Make visible and play audio
	text_instance.visible = true
	if config.audio:
		config.audio.play()
	
	# Start typewriter animation
	await animate_typewriter_text(text_instance, config.text)
	
	# Check if still valid after animation
	if not is_instance_valid(text_instance):
		return
	
	# Wait for display duration
	await get_tree().create_timer(display_duration).timeout
	
	# Clean up (with safety check)
	if is_instance_valid(text_instance):
		cleanup_text_instance(text_instance)
	
func animate_typewriter_text(text_instance: MeshInstance3D, full_text: String) -> void:
	if not is_instance_valid(text_instance):
		return
		
	var text_mesh = text_instance.mesh as TextMesh
	if not text_mesh:
		return
	
	# Clear text initially
	text_mesh.text = ""
	
	# Animate each character
	for i in range(full_text.length()):
		# Check if instance is still valid before each update
		if not is_spawning_texts or not text_instance or not is_instance_valid(text_instance):
			break
		
		text_mesh.text = full_text.substr(0, i + 1)
		await get_tree().create_timer(typewriter_speed).timeout
	
	# Ensure full text is shown (with safety check)
	if is_spawning_texts and text_instance and is_instance_valid(text_instance):
		text_mesh.text = full_text

func position_text_randomly(text_instance: MeshInstance3D) -> void:
	# Generate random position
	var random_x = randf_range(-spawn_range.x/2, spawn_range.x/2)
	var random_y = randf_range(-spawn_range.y/2, spawn_range.y/2)
	
	text_instance.position = Vector3(random_x, random_y, -spawn_range.z)
	
	# Random rotation for variety
	text_instance.rotation_degrees = Vector3(
		randf_range(-10, 10),
		randf_range(-10, 10),
		randf_range(-10, 10)
	)

func cleanup_text_instance(text_instance: MeshInstance3D) -> void:
	if not text_instance:
		return
	if is_instance_valid(text_instance):
		active_text_instances.erase(text_instance)
		text_instance.queue_free()

func cleanup_all_text_instances() -> void:
	for instance in active_text_instances.duplicate():  # Use duplicate() to avoid modifying array while iterating
		if instance and is_instance_valid(instance):
			instance.queue_free()
	active_text_instances.clear()
	
# Easy way to add new text configurations at runtime
func add_text_config(text: String, audio: AudioStreamPlayer3D, mesh_template: MeshInstance3D, weight: float = 1.0) -> void:
	var config = TextConfig.new(text, audio, mesh_template, weight)
	text_configs.append(config)
	if mesh_template:
		mesh_template.visible = false

# Your existing functions
func _on_delay_timeout() -> void:
	trigger_double_haptic_feedback()

func trigger_double_haptic_feedback() -> void:
	if watch_is_left:
		left_trigger_haptic_feedback()
		$watchNotif.play()
		await get_tree().create_timer(0.3).timeout
		left_trigger_haptic_feedback()
	else:
		right_trigger_haptic_feedback()
		$watchNotif.play()
		await get_tree().create_timer(0.3).timeout
		right_trigger_haptic_feedback()

func left_trigger_haptic_feedback(duration: float = 0.2, frequency: float = 0.5, amplitude: float = 0.8) -> void:
	$LeftHand.trigger_haptic_pulse("haptic", frequency, amplitude, duration, 0.0)

func right_trigger_haptic_feedback(duration: float = 0.2, frequency: float = 0.5, amplitude: float = 0.8) -> void:
	$RightHand.trigger_haptic_pulse("haptic", frequency, amplitude, duration, 0.0)
	
func _on_button_pressed(button_name: String):
	if $XRCamera3D and $RightHand and $LeftHand and !$XRCamera3D.current and button_name == "ax_button":
		self.current = true
		$XRCamera3D.current = true
	#if task_manager and notebook:
		#match button_name:
			##"trigger_click":
				##task_manager.refresh_all_tasks()
			#"ax_button": 
				##task_manager.display_tasks()
				##notebook.visible = !notebook.visible
				##task_manager.complete_task(0)
				## First check if note tutorial is visible and dismiss it
				#if note_tutorial_text.visible:
					#note_tutorial_text.visible = false
					#note_tutorial_dismissed = true
				#else:
					## Only toggle notebook if tutorial was already dismissed or not visible
					#notebook.visible = !notebook.visible
					
func _on_physical_increase(old_value: int, new_value: int):
	$XRCamera3D/FloatingIndicatorManager.show_typed_indicator(
		Vector3(-0.3, -0.5, -1.0),
		FloatingIndicatorManager.IndicatorType.PHYSICAL_GAIN
	)


func _on_physical_decrease(old_value: int, new_value: int):
	$XRCamera3D/FloatingIndicatorManager.show_typed_indicator(
		Vector3(-0.3, -0.5, -1.0),
		FloatingIndicatorManager.IndicatorType.PHYSICAL_LOSS
	)
	

func _on_emotional_increase(old_value: int, new_value: int):
	$XRCamera3D/FloatingIndicatorManager.show_typed_indicator(
		Vector3(0.3, -0.5, -1.0),
		FloatingIndicatorManager.IndicatorType.EMOTIONAL_GAIN
	)


func _on_emotional_decrease(old_value: int, new_value: int):
	$XRCamera3D/FloatingIndicatorManager.show_typed_indicator(
		Vector3(0.3, -0.5, -1.0),
		FloatingIndicatorManager.IndicatorType.EMOTIONAL_LOSS
	)

func _on_plushie_picked_up(pickable):
	if not $crying.playing:
		$crying.play()


func _on_plushie_released(pickable, by):
	$crying.stop()

func disable_teleport():
	$LeftHand/FunctionTeleport.enabled = false
	$RightHand/FunctionTeleport.enabled = false

func play_distraction_loop() -> void:
	var distraction_sounds = [sound_distraction1, sound_distraction2, sound_distraction3]
	
	while distraction_running:
		var random_sound = distraction_sounds[randi() % 3]
		random_sound.play()
		await get_tree().create_timer(5.0).timeout
