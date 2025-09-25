extends Node

# Change these to float for decimal values
var stimulation = 0.0 #[-2, 2]
var physical = 2.0 #[0, 4]
var emotional = 2.0 #[0, 4]

var foods_eaten_count: int = 0

signal stimulation_increase(old_value, new_value)
signal stimulation_decrease(old_value, new_value)
signal physical_increase(old_value, new_value)
signal physical_decrease(old_value, new_value)
signal emotional_increase(old_value, new_value)
signal emotional_decrease(old_value, new_value)
signal food_eaten(total_count: int)
signal eating_milestone(milestone: int)

	
func increase_stimulation():
	var old_val = stimulation
	stimulation += 1
	if stimulation == 3:
		stimulation = 2
	stimulation_increase.emit(old_val, stimulation)

func decrease_stimulation():
	var old_val = stimulation
	stimulation -= 1
	if stimulation == -3:
		stimulation = -2
	stimulation_decrease.emit(old_val, stimulation)
	
func increase_physical():
	var old_val = physical
	physical += 1
	if physical == 5:
		physical = 4
	physical_increase.emit(old_val, physical)
	
func decrease_physical():
	var old_val = physical
	physical -= 1
	if physical == -1:
		physical = 0
	physical_decrease.emit(old_val, physical)
	
func increase_emotional():
	var old_val = emotional
	emotional += 1
	if emotional == 5:
		emotional = 4
	emotional_increase.emit(old_val, emotional)

func decrease_emotional():
	var old_val = emotional
	emotional -= 1
	if emotional == -1:
		emotional = 0
	emotional_decrease.emit(old_val, emotional)
	

func add_food_eaten():
	foods_eaten_count += 1
	food_eaten.emit(foods_eaten_count)
	
	# Check for milestones
	if foods_eaten_count % 4 == 0:
		eating_milestone.emit(foods_eaten_count)
		# Increase physical and emotional by 1 every 6 foods
		increase_physical()
		increase_emotional()
		
