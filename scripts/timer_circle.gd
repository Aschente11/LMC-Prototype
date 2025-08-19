extends Node3D
class_name TimerCircle3D

@onready var progress_ring: MeshInstance3D = $ProgressRing
@onready var time_label: Label3D = $Billboard/TimeLabel

# Timer properties
var total_time: float = 0.0
var current_time: float = 0.0
var is_active: bool = false

# Visual properties
var start_color: Color = Color.GREEN
var warning_color: Color = Color.YELLOW
var critical_color: Color = Color.RED
var warning_threshold: float = 0.3  # 30% remaining

# Material reference
var ring_material: StandardMaterial3D

func _ready():
	# Get the material from the mesh
	if progress_ring and progress_ring.get_surface_override_material(0):
		ring_material = progress_ring.get_surface_override_material(0)
	
	# Initialize the ring to be invisible (no progress)
	update_progress_visual(0.0)

func _process(delta):
	if is_active and current_time > 0:
		current_time -= delta
		if current_time <= 0:
			current_time = 0
			is_active = false
			timer_finished()
		
		update_display()

# Called by parent script to start the timer
func start_timer(duration: float):
	total_time = duration
	current_time = duration
	is_active = true
	update_display()

# Called by parent script to pause/resume
func set_timer_active(active: bool):
	is_active = active

# Called by parent script to stop and reset
func stop_timer():
	is_active = false
	current_time = 0.0
	update_display()

# Called by parent script to add time
func add_time(additional_time: float):
	current_time += additional_time
	if current_time > total_time:
		total_time = current_time

# Called by parent script to set time directly
func set_time(new_time: float):
	current_time = new_time
	if total_time == 0.0:
		total_time = new_time

# Get current progress as percentage (0.0 to 1.0)
func get_progress() -> float:
	if total_time <= 0:
		return 0.0
	return (total_time - current_time) / total_time

# Get remaining time
func get_remaining_time() -> float:
	return current_time

# Check if timer is running
func is_timer_active() -> bool:
	return is_active

func update_display():
	var progress = get_progress()
	var remaining_ratio = current_time / total_time if total_time > 0 else 0.0
	
	# Update visual progress
	update_progress_visual(progress)
	
	# Update color based on remaining time
	update_color(remaining_ratio)
	
	# Update time label
	update_time_label()

func update_progress_visual(progress: float):
	# Create a shader or modify the torus to show progress
	# For now, we'll use transparency and scaling as a simple approach
	
	if progress_ring:
		# Method 1: Use transparency to show progress
		if ring_material:
			# Make the ring more opaque as progress increases
			var alpha = progress * 0.8 + 0.2  # Keep minimum visibility
			var current_color = ring_material.albedo_color
			ring_material.albedo_color = Color(current_color.r, current_color.g, current_color.b, alpha)
		
		# Method 2: Scale the ring (alternative approach)
		# var scale_factor = 0.1 + (progress * 0.9)  # Scale from 10% to 100%
		# progress_ring.scale = Vector3(scale_factor, scale_factor, 1.0)

func update_color(remaining_ratio: float):
	if not ring_material:
		return
	
	var target_color: Color
	var emission_color: Color
	
	if remaining_ratio > warning_threshold:
		# Normal state - green
		target_color = start_color
		emission_color = Color(0, 0.4, 0, 1)
		# Warning state - yellow
		target_color = warning_color
		emission_color = Color(0.4, 0.4, 0, 1)
	else:
		# Critical state - red
		target_color = critical_color
		emission_color = Color(0.4, 0, 0, 1)
		
		# Add pulsing effect when critical

	
	# Apply colors
	ring_material.albedo_color = Color(target_color.r, target_color.g, target_color.b, ring_material.albedo_color.a)
	ring_material.emission = emission_color

func update_time_label():
	if time_label:
		var minutes = int(current_time) / 60
		var seconds = int(current_time) % 60
		time_label.text = "%02d:%02d" % [minutes, seconds]

func timer_finished():
	# Emit signal or call parent method when timer finishes
	if get_parent().has_method("on_timer_finished"):
		get_parent().on_timer_finished()
	
	# You can also emit a signal if preferred
	# timer_finished_signal.emit()

# Alternative method using a more advanced progress visualization
# This creates a partial torus based on progress
func create_progress_torus(progress: float):
	if not progress_ring:
		return
	
	# This would require creating a custom mesh or using a shader
	# For a proper circular progress, you might want to use a custom shader
	# or create the mesh procedurally
	
	# Example shader approach (you'd need to create this shader):
	# ring_material.set_shader_parameter("progress", progress)

# Signal definition (uncomment if you want to use signals)
# signal timer_finished_signal
# signal timer_updated_signal(remaining_time: float, progress: float)

# Optional: Custom shader parameters for more advanced progress visualization
func setup_progress_shader():
	# If you create a custom shader for the progress ring,
	# you can set up shader parameters here
	if ring_material and ring_material.shader:
		ring_material.set_shader_parameter("progress", 0.0)
		ring_material.set_shader_parameter("inner_radius", 0.95)
		ring_material.set_shader_parameter("outer_radius", 1.05)
