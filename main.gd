extends Node3D
var xr_interface: XRInterface
@onready var environment_node = $WorldEnvironment
var normal_environment: Environment
var blur_environment: Environment
var current_stimulation = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully!")
		
		#Turn-off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		#Change our main viewport output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected.")
	
	# Setup blur environments
	setup_blur_environments()
	call_deferred("check_initial_state")
	
	GlobalVar.stimulation_increase.connect(_on_stimulation_increase)
	GlobalVar.stimulation_decrease.connect(_on_stimulation_decrease)

func setup_blur_environments():
	# Store the normal environment
	if environment_node.environment:
		normal_environment = environment_node.environment
	else:
		# Create a new environment if none exists
		normal_environment = Environment.new()
		environment_node.environment = normal_environment
	
	# Create the blur environment
	create_blur_environment()

func create_blur_environment():
	blur_environment = normal_environment.duplicate()
	
	# Setup blur effects
	blur_environment.glow_enabled = true
	blur_environment.glow_intensity = 2.0
	blur_environment.glow_strength = 1.5
	blur_environment.glow_mix = 0.9
	blur_environment.glow_bloom = 0.4
	blur_environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	
	# Add fog blur
	blur_environment.fog_enabled = true
	blur_environment.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	blur_environment.fog_density = 0.02
	blur_environment.fog_light_color = Color(0.9, 0.9, 1.0, 1.0)
	blur_environment.fog_light_energy = 0.8
	
	# Adjust colors for overstimulation effect
	blur_environment.adjustment_enabled = true
	blur_environment.adjustment_brightness = 1.2
	blur_environment.adjustment_contrast = 0.9
	blur_environment.adjustment_saturation = 0.8

func check_initial_state() -> void:
	_on_stimulation_changed(GlobalVar.stimulation)

# Connect to the same signals as the smartwatch for consistency
func _on_stimulation_increase(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_decrease(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_changed(new_stimulation_value: int) -> void:
	if new_stimulation_value == 2:
		apply_blur_effect()
	elif new_stimulation_value < 2:
		remove_blur_effect()

func apply_blur_effect():
	if environment_node.environment != blur_environment:
		print("Applying blur effect - stimulation level: ", current_stimulation)
		
		# Smooth transition to blur
		var tween = create_tween()
		tween.tween_callback(func(): environment_node.environment = blur_environment)

func remove_blur_effect():
	if environment_node.environment != normal_environment:
		print("Removing blur effect - stimulation level: ", current_stimulation)
		
		# Smooth transition back to normal
		var tween = create_tween()
		tween.tween_callback(func(): environment_node.environment = normal_environment)
