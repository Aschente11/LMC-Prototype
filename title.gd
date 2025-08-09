extends Node3D

@onready var title_text: MeshInstance3D = $TitleText
@onready var bg_sounds: AudioStreamPlayer3D = $BGsounds
@onready var knife: MeshInstance3D = $knife
@onready var cat: MeshInstance3D = $cat

# Store original position and rotation
var original_position: Vector3
var original_rotation: Vector3
var time_passed: float = 0.0

# Knife animation properties
@export var knife_rotation_speed: Vector3 = Vector3(0, 0, 90)
@export var knife_orbit_center: Vector3 = Vector3(0, 50, 0)
@export var knife_orbit_radius: float = 25.0
@export var knife_orbit_speed: float = 1.0

# Cat animation properties
@export var cat_rotation_speed: Vector3 = Vector3(90, 0, 0)  # Rotate around Y-axis
@export var cat_orbit_center: Vector3 = Vector3(0, 50, 0)    # Center point for cat orbit
@export var cat_orbit_radius: float = 30.0                   # Radius of cat's orbit
@export var cat_orbit_speed: float = 0.8                     # Speed of cat's orbit

func _ready():
	# Store the original transform
	original_position = title_text.position
	original_rotation = title_text.rotation_degrees
	
	# Start background sounds
	bg_sounds.play()

func _process(delta):
	time_passed += delta
	
	# Animate title text
	simple_bounce()
	
	# Animate knife
	animate_knife()
	
	# Animate cat
	animate_cat()

# Knife animation function (unchanged)
func animate_knife():
	# Rotate the knife on its own axis
	knife.rotation_degrees += knife_rotation_speed * get_process_delta_time()
	
	# Orbit around the specified center point
	var angle = time_passed * knife_orbit_speed
	
	# Calculate orbital position
	knife.position.x = knife_orbit_center.x + cos(angle) * knife_orbit_radius
	knife.position.z = knife_orbit_center.z + sin(angle) * knife_orbit_radius
	knife.position.y = knife_orbit_center.y

# Cat animation function - orbits around Z-axis
func animate_cat():
	# Rotate the cat on its own axis (around Y-axis for a natural spinning motion)
	cat.rotation_degrees += cat_rotation_speed * get_process_delta_time()
	
	# Orbit around the Z-axis (circular motion in X-Y plane)
	var angle = time_passed * cat_orbit_speed
	
	# Calculate orbital position (orbiting around Z-axis means moving in X-Y plane)
	cat.position.x = cat_orbit_center.x + cos(angle) * cat_orbit_radius
	cat.position.y = cat_orbit_center.y + sin(angle) * cat_orbit_radius
	cat.position.z = cat_orbit_center.z

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
