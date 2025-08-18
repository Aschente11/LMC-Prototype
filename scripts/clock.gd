extends Node3D

@onready var time_label: Label = $Time/SubViewport/Control/Label
@onready var subviewport: SubViewport = $Time/SubViewport

func _ready():
	GlobalTime.time_updated.connect(_on_time_updated)

	_update_time_display(GlobalTime.get_formatted_time())

func _on_time_updated(hour: int, minute: int, is_pm: bool, formatted_time: String):
	_update_time_display(formatted_time)

func _update_time_display(time_string: String):
	time_label.text = time_string
