extends Node

var stimulation = 0

# Signal to notify other parts of the game when stimulation changes
signal stimulation_changed(new_value)

func increase_stimulation():
	stimulation += 1
	stimulation_changed.emit(stimulation)

func decrease_stimulation():
	stimulation -= 1
	stimulation_changed.emit(stimulation)
