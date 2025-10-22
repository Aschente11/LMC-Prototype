extends Node

signal typing_started
signal typing_stopped

var is_typing: bool = false

func start_typing():
	if not is_typing:
		is_typing = true
		typing_started.emit()

func stop_typing():
	if is_typing:
		is_typing = false
		typing_stopped.emit()
