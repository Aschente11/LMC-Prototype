class_name Task

extends Node3D

enum Priority {
	LOW,
	MEDIUM,
	HIGH
}

var text: String
var priority: Priority
var priority_color: Color

func _init(task_text: String, task_priority: Priority):
	text = task_text
	priority = task_priority
	priority_color = get_priority_color(priority)

func get_priority_color(p: Priority) -> Color:
	match p:
		Priority.LOW:
			return Color.GREEN
		Priority.MEDIUM:
			return Color.YELLOW
		Priority.HIGH:
			return Color.RED
	return Color.WHITE

func get_priority_text(p: Priority) -> String:
	match p:
		Priority.LOW:
			return "LOW"
		Priority.MEDIUM:
			return "MEDIUM"
		Priority.HIGH:
			return "HIGH"
	return "UNKNOWN"
	
func get_priority_weight(p: Priority) -> int:
	match priority:
		Priority.HIGH:
			return 4
		Priority.MEDIUM:
			return 2
		Priority.LOW:
			return 1
	return 1
