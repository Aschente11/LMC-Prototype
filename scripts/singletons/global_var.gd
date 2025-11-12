extends Node

# Ordered tasks
var tasks := [
	"cook and eat \n breakfast",
	"unpack my \n things",
	"I need to \n sleep early"
]

# Index of the task currently available to write
var current_task_index := 0
# Whether the current task is already being written on
var current_task_assigned := false

# Change these to float for decimal values
var stimulation = 3.0 #[-2, 2]
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

const NORMAL_STIMULATION = 3.0

# Automatically updates stimulation based on physical and emotional needs
func update_stimulation():
	var old_val = stimulation
	var new_val = stimulation
	
	# Calculate average of physical and emotional
	var average_needs = (physical + emotional) / 2.0
	
	# If average is below 3, decrease stimulation
	if average_needs < 3.0:
		new_val = stimulation - 1
	# If average is 3 or above, regulate back to normal
	elif average_needs >= 3.0:
		new_val = NORMAL_STIMULATION
	
	# Clamp stimulation to valid range [-2, 2]
	new_val = clamp(new_val, -2, 2)
	
	# Only update and emit if value actually changed
	if new_val != old_val:
		stimulation = new_val
		if old_val > stimulation:
			stimulation_decrease.emit(old_val, stimulation)
		elif old_val < stimulation:
			stimulation_increase.emit(old_val, stimulation)

func regulate_stimulation():
	var old_val = stimulation
	stimulation = NORMAL_STIMULATION
	# Emit appropriate signal based on whether it increased or decreased
	if old_val > stimulation:
		stimulation_decrease.emit(old_val, stimulation)
	elif old_val < stimulation:
		stimulation_increase.emit(old_val, stimulation)

func increase_physical():
	var old_val = physical
	physical += 1
	if physical == 5:
		physical = 4
	physical_increase.emit(old_val, physical)
	update_stimulation()  # Check stimulation after physical changes
	
func decrease_physical():
	var old_val = physical
	physical -= 1
	if physical == -1:
		physical = 0
	physical_decrease.emit(old_val, physical)
	update_stimulation()  # Check stimulation after physical changes
	
func increase_emotional():
	var old_val = emotional
	emotional += 1
	if emotional == 5:
		emotional = 4
	emotional_increase.emit(old_val, emotional)
	update_stimulation()  # Check stimulation after emotional changes
	
func decrease_emotional():
	var old_val = emotional
	emotional -= 1
	if emotional == -1:
		emotional = 0
	emotional_decrease.emit(old_val, emotional)
	update_stimulation()  # Check stimulation after emotional changes
	
func add_food_eaten():
	foods_eaten_count += 1
	food_eaten.emit(foods_eaten_count)
	
	# Check for milestones
	if foods_eaten_count % 4 == 0:
		eating_milestone.emit(foods_eaten_count)
		# Increase physical and emotional by 1 every 4 foods
		increase_physical()
		increase_emotional()
		
# Called by a Post-it when it wants to get something to write
func request_task() -> String:
	if current_task_index >= tasks.size():
		return ""  # no more tasks
	# Only give text if it's not already being written on
	if not current_task_assigned:
		current_task_assigned = true
		return tasks[current_task_index]
	else:
		return ""  # someone is still writing this one
		
# Called when a Post-it is finished being written
func mark_current_done():
	if current_task_index < tasks.size():
		current_task_index += 1
	current_task_assigned = false
