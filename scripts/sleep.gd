extends Event
@onready var tired_sfx: AudioStreamPlayer = $"../tired"

func _on_event_started() -> void:
	print("bakit")
	var tired_text = get_tree().get_first_node_in_group("tired_text")
	await get_tree().create_timer(6.0).timeout
	tired_text.visible = true
	tired_sfx.play()
	
