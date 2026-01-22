@warning_ignore("missing_tool")
extends Event

func _ready() -> void:
	GlobalVar.eating_milestone.connect(_on_eating_milestone)

func _on_eating_milestone(_milestone: int):
	close_event()
	print("BFAST EVENT SHOULDVE FINISHED")
