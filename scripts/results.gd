extends Control

var random_text: Array[String] = ["Do androids dream of electric sheep?", "Lorem ipsum dolor sit...",
	"I have no mouth and I must scream", "WhAt is liFe even aBOut", "Jinkies!", "6 7 to jog", "i eepy",
	"I'm just ken...", "Never gonna give you up"]

func update(day: int, tasksCompleted: int, tasksNumber: int):
	$CenterContainer/VBoxContainer/HBoxContainer2/TitleLabel.text = "Day " + str(day)
	
	var rank = get_rank(float(tasksCompleted)/float(tasksNumber))
	var color
	
	if rank == "F":
		color = Color.DARK_RED
	elif rank == "C" or rank == "B":
		color = Color.YELLOW
	else:
		color = Color.LAWN_GREEN
	
	$CenterContainer/VBoxContainer/RankLabel.text = rank
	$CenterContainer/VBoxContainer/RankLabel.label_settings.font_color = color
	
	$CenterContainer/VBoxContainer/HBoxContainer/TasksLabel.text = "{}/{}".format([clampi(tasksCompleted, 0, tasksNumber), tasksNumber], "{}")
	
	$CenterContainer/VBoxContainer/MessageLabel.text = random_text.pick_random()

func get_rank(p: float) -> String:
	if p == 0.0:
		return "F"
	elif p < 0.25:
		return "C"
	elif p < 0.50:
		return "B"
	elif p < 0.75:
		return "A"
	return "S+"
