# In cardboard_box.gd
extends StaticBody3D

signal box_emptied  # Custom signal

@onready var detection_area: Area3D = $"Detection Area"
var object_count: int = 3

func _ready() -> void:
	detection_area.body_exited.connect(_on_body_exited)
	
	# Connect the signal directly to the event's close_event method
	var unpack_event = get_node("Unpack things")
	if unpack_event:
		box_emptied.connect(unpack_event.close_event)
	else:
		print("ERROR: Unpack things event not found!")

func _on_body_exited(body: Node3D) -> void:
	if should_track_object(body):
		object_count -= 1
		
		if object_count <= 0:
			print("Box is empty! Emitting signal...")
			box_emptied.emit()  # Emit the signal
			GlobalVar.decrease_stimulation()
			GlobalVar.decrease_stimulation()
			GlobalVar.decrease_physical()
			GlobalVar.decrease_physical()
			GlobalVar.decrease_physical()
			GlobalVar.decrease_emotional()
			GlobalVar.decrease_emotional()

func should_track_object(body: Node3D) -> bool:
	return body.is_in_group("tool")
