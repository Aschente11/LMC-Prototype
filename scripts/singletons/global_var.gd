extends Node

# Change these to float for decimal values
var stimulation = 0.0 #[-2, 2]
var physical = 2.0 #[0, 4]
var emotional = 2.0 #[0, 4]

signal stimulation_increase(new_value)
signal stimulation_decrease(new_value)
signal physical_increase(new_value)
signal physical_decrease(new_value)
signal emotional_increase(new_value)
signal emotional_decrease(new_value)

	
func increase_stimulation():
	stimulation += 1
	if stimulation == 3:
		stimulation = 2
	stimulation_increase.emit(stimulation)

func decrease_stimulation():
	stimulation -= 1
	if stimulation == -3:
		stimulation = -2
	stimulation_decrease.emit(stimulation)
	
func increase_physical():
	physical += 1
	if physical == 5:
		physical = 4
	physical_increase.emit(physical)
	
func decrease_physical():
	physical -= 1
	if physical == -1:
		physical = 0
	physical_decrease.emit(physical)
	
func increase_emotional():
	emotional += 1
	if emotional == 5:
		emotional = 4
	emotional_increase.emit(emotional)

func decrease_emotional():
	emotional -= 1
	if emotional == -1:
		emotional = 0
	emotional_decrease.emit(emotional)
	
