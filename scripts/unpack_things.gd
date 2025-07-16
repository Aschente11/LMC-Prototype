extends Event

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
