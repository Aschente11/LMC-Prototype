extends Event
@onready var detection_area: Area3D = $"../Detection Area"
var objects_in_box: Array = []

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered_box)
	detection_area.body_exited.connect(_on_body_exited_box)
	
	# Detect objects already in the box when scene loads
	await get_tree().process_frame  # Wait one frame for everything to initialize
	_detect_initial_objects()

func _detect_initial_objects() -> void:
	# Get all bodies currently overlapping with the detection area
	var overlapping_bodies = detection_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body not in objects_in_box:
			objects_in_box.append(body)
			print("Initial object detected in box: ", body.name)
	
	print("Total objects in box at start: ", objects_in_box.size())

func _on_event_started() -> void:
	var need_unpack_text = get_tree().get_first_node_in_group("need_unpack_text")
	await get_tree().create_timer(6.0).timeout
	need_unpack_text.visible = true

func _on_event_ended() -> void:
	var need_unpack_text = get_tree().get_first_node_in_group("need_unpack_text")
	need_unpack_text.visible = false
	
	var tired_text = get_tree().get_first_node_in_group("tired_text")
	await get_tree().create_timer(6.0).timeout
	tired_text.visible = true

func _on_body_entered_box(body: Node3D) -> void:
	# Add object to tracking array
	if body not in objects_in_box:
		objects_in_box.append(body)
		print("Object entered box: ", body.name)

func _on_body_exited_box(body: Node3D) -> void:
	# Remove object from tracking array
	if body in objects_in_box:
		objects_in_box.erase(body)
		print("Object left box: ", body.name)
		
		# Check if box is now empty
		if objects_in_box.is_empty():
			print("Box is empty - ending event")
			close_event()
