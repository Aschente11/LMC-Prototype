extends Node3D

@onready var title_text: MeshInstance3D = $TitleText
@onready var bg_sounds: AudioStreamPlayer3D = $BGsounds

# Store original position and rotation
var original_position: Vector3
var original_rotation: Vector3
var time_passed: float = 0.0

func _ready():
	# Store the original transform
	original_position = title_text.position
	original_rotation = title_text.rotation_degrees
	
	# Start background sounds
	bg_sounds.play()

func _process(delta):
	time_passed += delta
	
	# Method 1: Simple vertical bounce with sine wave
	simple_bounce()
	
	# Method 2: More complex bouncing with scaling (uncomment to use instead)
	# complex_bounce()
	
	# Method 3: Bouncing with rotation (uncomment to use instead)
	# bounce_with_rotation()

# Simple vertical bouncing
func simple_bounce():
	var bounce_height = 2.0  # How high to bounce
	var bounce_speed = 2.0   # How fast to bounce
	
	var bounce_offset = sin(time_passed * bounce_speed) * bounce_height
	title_text.position = original_position + Vector3(0, bounce_offset, 0)

# More complex bouncing with scaling effect
func complex_bounce():
	var bounce_height = 1.5
	var bounce_speed = 2.5
	var scale_amount = 0.1  # How much to scale
	
	# Vertical bounce
	var bounce_offset = sin(time_passed * bounce_speed) * bounce_height
	title_text.position = original_position + Vector3(0, bounce_offset, 0)
	
	# Scale effect (slightly larger when at the top of bounce)
	var scale_factor = 1.0 + (sin(time_passed * bounce_speed) * scale_amount)
	title_text.scale = Vector3(scale_factor, scale_factor, scale_factor)

# Bouncing with gentle rotation
func bounce_with_rotation():
	var bounce_height = 1.8
	var bounce_speed = 2.2
	var rotation_amount = 5.0  # Degrees
	
	# Vertical bounce
	var bounce_offset = sin(time_passed * bounce_speed) * bounce_height
	title_text.position = original_position + Vector3(0, bounce_offset, 0)
	
	# Gentle rotation on Z-axis
	var rotation_offset = sin(time_passed * bounce_speed * 0.7) * rotation_amount
	title_text.rotation_degrees = original_rotation + Vector3(0, 0, rotation_offset)

# Alternative: Elastic bounce effect (call this instead of simple_bounce)
func elastic_bounce():
	var bounce_height = 2.5
	var bounce_speed = 1.8
	
	# Create an elastic effect using multiple sine waves
	var primary_bounce = sin(time_passed * bounce_speed) * bounce_height
	var secondary_bounce = sin(time_passed * bounce_speed * 3.0) * (bounce_height * 0.2)
	
	var total_bounce = primary_bounce + secondary_bounce
	title_text.position = original_position + Vector3(0, total_bounce, 0)

# Alternative: Pulsing glow effect (if you want to animate the material)
func pulsing_glow():
	var pulse_speed = 3.0
	var min_energy = 0.3
	var max_energy = 0.8
	
	var pulse_factor = (sin(time_passed * pulse_speed) + 1.0) * 0.5  # 0 to 1
	var current_energy = min_energy + (pulse_factor * (max_energy - min_energy))
	
	# Assuming your text material has emission
	var material = title_text.get_surface_override_material(0)
	if material:
		material.emission_energy_multiplier = current_energy

# Method for smooth bouncing using Tween (more performance friendly)
func start_tween_bounce():
	var tween = create_tween()
	tween.set_loops()  # Loop forever
	
	# Bounce up
	tween.tween_property(title_text, "position", original_position + Vector3(0, 2.0, 0), 0.8)
	tween.tween_property(title_text, "position", original_position, 0.8)
	
	# You can also chain scale or rotation animations
	tween.parallel().tween_property(title_text, "scale", Vector3(1.1, 1.1, 1.1), 0.8)
	tween.parallel().tween_property(title_text, "scale", Vector3(1.0, 1.0, 1.0), 0.8)
