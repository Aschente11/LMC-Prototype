extends Event
@onready var unpack_sfx: AudioStreamPlayer = $"../unpack"
@onready var tired_sfx: AudioStreamPlayer = $"../tired"

func _on_event_started() -> void:
	var need_unpack_text = get_tree().get_first_node_in_group("need_unpack_text")
	await get_tree().create_timer(6.0).timeout
	need_unpack_text.visible = true
	unpack_sfx.play()

func _on_event_ended() -> void:
	print("Event ended")
	var need_unpack_text = get_tree().get_first_node_in_group("need_unpack_text")
	if need_unpack_text == null:
		print("ERROR: need_unpack_text node not found!")
		# Check if any nodes exist in the group
		var nodes_in_group = get_tree().get_nodes_in_group("need_unpack_text")
		print("Nodes in group: ", nodes_in_group.size())
		return
	need_unpack_text.visible = false
	var tired_text = get_tree().get_first_node_in_group("tired_text")
	await get_tree().create_timer(6.0).timeout
	tired_text.visible = true
	tired_sfx.play()
