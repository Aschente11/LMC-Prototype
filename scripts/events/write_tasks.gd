extends Event


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_event_started():
	pass
	
func _on_writing_done():
	close_event()
	$"../../Audio/notes_done".play()
