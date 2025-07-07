# fridge_door_controller.gd
# Enhanced version with better debugging and alternative trigger methods

extends Node3D

@export var door_open_angle: float = 90.0
@export var door_open_speed: float = 2.0
@export var door_axis: Vector3 = Vector3.UP
@export var use_simple_trigger: bool = true  # Use area enter/exit instead of swipe

var is_door_open: bool = false
var door_hinge: Node3D
var original_rotation: Vector3
var target_rotation: Vector3
var is_animating: bool = false
var ois_receiver: Node3D

func _ready():
	print("Fridge Door Controller Ready")
	
	# Find the door hinge - try multiple possible paths
	door_hinge = find_door_hinge()
	if door_hinge:
		original_rotation = door_hinge.rotation_degrees
		target_rotation = original_rotation
		print("Door hinge found: ", door_hinge.name)
		print("Original rotation: ", original_rotation)
	else:
		print("ERROR: Could not find door hinge!")
	
	# Find the OIS receiver
	ois_receiver = find_ois_receiver()
	if ois_receiver:
		print("OIS Receiver found: ", ois_receiver.name)
		# Connect to any available signals
		connect_ois_signals()
	else:
		print("ERROR: Could not find OIS receiver!")

func find_door_hinge() -> Node3D:
	# Try different possible paths to find the door
	var possible_paths = [
		"../Fridge B_001",
		"../../Fridge B_001", 
		"../",
		"../../",
		get_parent()
	]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node:
			print("Testing door hinge path: ", path, " -> ", node.name)
			return node
	
	return null

func find_ois_receiver() -> Node3D:
	# Find the OIS receiver in the scene
	var possible_paths = [
		"../OISWipeReceiver",
		"OISWipeReceiver",
		"../OISDirectionalSwipeReceiver"
	]
	
	for path in possible_paths:
		var node = get_node_or_null(path)
		if node:
			return node
	
	return null

func connect_ois_signals():
	if not ois_receiver:
		return
		
	# Try to connect common OIS signals
	var signals_to_connect = [
		"swipe_detected",
		"interaction_started", 
		"interaction_ended",
		"area_entered",
		"area_exited",
		"body_entered",
		"body_exited"
	]
	
	for signal_name in signals_to_connect:
		if ois_receiver.has_signal(signal_name):
			var callable_name = "_on_" + signal_name
			if has_method(callable_name):
				ois_receiver.connect(signal_name, Callable(self, callable_name))
				print("Connected signal: ", signal_name)

func _process(delta):
	if is_animating and door_hinge:
		door_hinge.rotation_degrees = door_hinge.rotation_degrees.lerp(target_rotation, door_open_speed * delta)
		
		if door_hinge.rotation_degrees.distance_to(target_rotation) < 0.1:
			door_hinge.rotation_degrees = target_rotation
			is_animating = false
			print("Door animation complete")

func toggle_door():
	print("=== TOGGLE DOOR CALLED ===")
	if is_animating:
		print("Door is animating, ignoring toggle")
		return
	
	if not door_hinge:
		print("ERROR: No door hinge found!")
		return
	
	is_door_open = !is_door_open
	
	if is_door_open:
		target_rotation = original_rotation + (door_axis * door_open_angle)
		print("Opening fridge door to: ", target_rotation)
	else:
		target_rotation = original_rotation
		print("Closing fridge door to: ", target_rotation)
	
	is_animating = true

# OIS Signal handlers
func _on_swipe_detected(direction: Vector3):
	print("=== SWIPE DETECTED ===")
	print("Direction: ", direction)
	toggle_door()

func _on_interaction_started():
	print("=== INTERACTION STARTED ===")
	if use_simple_trigger:
		toggle_door()

func _on_interaction_ended():
	print("=== INTERACTION ENDED ===")

func _on_area_entered(area):
	print("=== AREA ENTERED ===")
	print("Area: ", area)
	if use_simple_trigger:
		toggle_door()

func _on_area_exited(area):
	print("=== AREA EXITED ===")
	print("Area: ", area)

func _on_body_entered(body):
	print("=== BODY ENTERED ===")
	print("Body: ", body)
	if use_simple_trigger:
		toggle_door()

func _on_body_exited(body):
	print("=== BODY EXITED ===")
	print("Body: ", body)

# Manual trigger for testing
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F:
			print("Manual door toggle (F key)")
			toggle_door()
