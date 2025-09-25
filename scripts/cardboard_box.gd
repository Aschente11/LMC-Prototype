extends StaticBody3D
@onready var detection_area: Area3D = $"Detection Area"
@onready var tired_sfx = $tired
var object_count: int = 2
var tired_text_timer: Timer

func _ready() -> void:
	detection_area.body_exited.connect(_on_body_exited)
	
	# Setup timer for tired text
	tired_text_timer = Timer.new()
	add_child(tired_text_timer)
	tired_text_timer.wait_time = 0.1  # Short delay to ensure scene is ready
	tired_text_timer.one_shot = true
	tired_text_timer.timeout.connect(_on_tired_timer_timeout)

func _on_body_exited(body: Node3D) -> void:
	print(body)
	if should_track_object(body):
		object_count -= 1
		
		if object_count <= 0:
			print("Box is empty! Emitting signal...")
			#GlobalVar.decrease_stimulation()
			#GlobalVar.decrease_stimulation()
			GlobalVar.decrease_physical()
			GlobalVar.decrease_physical()
			GlobalVar.decrease_physical()
			GlobalVar.decrease_emotional()
			GlobalVar.decrease_emotional()
			
			# Start the timer instead of directly accessing the node
			tired_text_timer.start()

func _on_tired_timer_timeout():
	var tired_text = get_tree().get_first_node_in_group("tired_text")
	if tired_text:
		tired_text.visible = true
		tired_sfx.play()
		print("Tired text shown successfully via timer")
	else:
		print("tired_text not found even after timer - checking scene structure...")
		# Optional: try a longer delay
		tired_text_timer.wait_time = 0.5
		tired_text_timer.start()

func should_track_object(body: Node3D) -> bool:
	return body.is_in_group("tool")

func _on_unpack_things_event_ended() -> void:
	pass # Replace with function body.
