extends Area3D

@export var dialogue_key = ""
var area_active = false

func _input(event):
	if area_active and event.is_action_pressed("ui_accept"):
		DialogueManager.emit_signal("display_dialogue", dialogue_key)

func _on_area_entered(area: Area3D) -> void:
	area_active = true
