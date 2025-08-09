extends MeshInstance3D

# Rotation speed in degrees per second
@export var rotation_speed: Vector3 = Vector3(0, 0, 90)

# Orbital motion properties
@export var orbit_center: Vector3 = Vector3(0, 50, 0)
@export var orbit_radius: float = 25.0
@export var orbit_speed: float = 1.0

var time_passed: float = 0.0

func _process(delta):
	time_passed += delta
	
	# Rotate the knife on its own axis
	rotation_degrees += rotation_speed * delta
	
	# Orbit around the specified center point
	var angle = time_passed * orbit_speed
	
	# Calculate orbital position
	position.x = orbit_center.x + cos(angle) * orbit_radius
	position.z = orbit_center.z + sin(angle) * orbit_radius
	position.y = orbit_center.y
