extends Area3D

@export var door_rigidbody: RigidBody3D
@export var open_force: float = 5.0
@export var close_force: float = 3.0
@export var max_open_angle: float = 120.0

var is_grabbed: bool = false
var vr_controller: XRController3D

func _ready():
	# Connect VR controller signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		vr_controller = body

func _on_body_exited(body):
	if body == vr_controller:
		vr_controller = null
		is_grabbed = false

func _process(delta):
	if vr_controller and Input.is_action_pressed("vr_grip"):
		if not is_grabbed:
			is_grabbed = true
		_handle_door_interaction()

func _handle_door_interaction():
	if not door_rigidbody:
		return
	
	# Get controller movement direction
	var controller_velocity = vr_controller.get_velocity()
	var door_forward = door_rigidbody.global_transform.basis.z
	
	# Calculate if pulling or pushing
	var dot_product = controller_velocity.dot(door_forward)
	
	if dot_product > 0.1:  # Pulling
		door_rigidbody.apply_torque(Vector3(0, open_force, 0))
	elif dot_product < -0.1:  # Pushing
		door_rigidbody.apply_torque(Vector3(0, -close_force, 0))
