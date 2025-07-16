extends Node

var stimulation = 0

# Signal to notify other parts of the game when stimulation changes
signal stimulation_increase(new_value)
signal stimulation_decrease(new_value)

func increase_stimulation():
	stimulation += 1
	stimulation_increase.emit(stimulation)

func decrease_stimulation():
	stimulation -= 1
	stimulation_decrease.emit(stimulation)
