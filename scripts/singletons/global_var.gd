extends Node

# Change these to float for decimal values
var stimulation = 2.0
var physical = 2.0
var emotional = 2.0

signal stimulation_increase(new_value)
signal stimulation_decrease(new_value)
signal physical_increase(new_value)
signal physical_decrease(new_value)
signal emotional_increase(new_value)
signal emotional_decrease(new_value)

func _process(delta: float) -> void:
	print(physical)
	
func increase_stimulation():
	stimulation += 1
	stimulation_increase.emit(stimulation)

func decrease_stimulation():
	stimulation -= 1
	stimulation_decrease.emit(stimulation)
	
func increase_physical():
	physical += 1
	physical_increase.emit(physical)

func decrease_physical():
	physical -= 1
	physical_decrease.emit(physical)
	
func increase_emotional():
	emotional += 1
	emotional_increase.emit(emotional)

func decrease_emotional():
	emotional -= 1
	emotional_decrease.emit(emotional)
