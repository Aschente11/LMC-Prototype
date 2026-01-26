extends Node

# Change these to float for decimal values
var stimulation = 3.0 #[1, 5]
var physical = 3.0 #[1, 5]
var emotional = 3.0 #[1, 5]
var foods_eaten_count: int = 0
var dust_cleaned_count: int = 0

const MIN_STIMULATION = 1.0
const MAX_STIMULATION = 5.0
const MIN_PHYSICAL = 1.0
const MAX_PHYSICAL = 5.0
const MIN_EMOTIONAL = 1.0
const MAX_EMOTIONAL = 5.0
const NORMAL_STIMULATION = 3.0

signal stimulation_increase(old_value, new_value)
signal stimulation_decrease(old_value, new_value)
signal physical_increase(old_value, new_value)
signal physical_decrease(old_value, new_value)
signal emotional_increase(old_value, new_value)
signal emotional_decrease(old_value, new_value)
signal food_eaten(total_count: int)
signal eating_milestone(milestone: int)
signal cleaning_milestone(milestone: int)


var _update_pending = false

func default_state():
	var old_stim = stimulation
	var old_phys = physical
	var old_emo = emotional
	
	stimulation = 3.0
	physical = 3.0
	emotional = 3.0
	foods_eaten_count = 0  
	dust_cleaned_count = 0
	
	if old_stim != stimulation:
		if old_stim > stimulation:
			stimulation_decrease.emit(old_stim, stimulation)
		else:
			stimulation_increase.emit(old_stim, stimulation)
	
	if old_phys != physical:
		if old_phys > physical:
			physical_decrease.emit(old_phys, physical)
		else:
			physical_increase.emit(old_phys, physical)
	
	if old_emo != emotional:
		if old_emo > emotional:
			emotional_decrease.emit(old_emo, emotional)
		else:
			emotional_increase.emit(old_emo, emotional)

	
func update_stimulation():
	_update_pending = false
	var old_val = stimulation
	var new_val = stimulation
	
	# If both are at 3, regulate stimulation back to normal
	if physical == 3.0 and emotional == 3.0:
		new_val = NORMAL_STIMULATION
	# If both physical and emotional are below 3, stimulation minus 1
	elif physical < 3.0 and emotional < 3.0:
		new_val = stimulation - 1
	# If only emotional is below 3, stimulation plus 1
	elif emotional < 3.0:
		new_val = stimulation + 1
	# If only physical is below 3, stimulation minus 1
	elif physical < 3.0:
		new_val = stimulation - 1
	
	# Clamp stimulation to valid range [1, 5]
	new_val = clamp(new_val, 1, 5)
	
	# Only update and emit if value actually changed
	if new_val != old_val:
		stimulation = new_val
		if old_val > stimulation:
			stimulation_decrease.emit(old_val, stimulation)
		elif old_val < stimulation:
			stimulation_increase.emit(old_val, stimulation)
		
func _schedule_update():
	if not _update_pending:
		_update_pending = true
		call_deferred("update_stimulation")

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
	if physical == MAX_PHYSICAL:
		physical = 5
	physical_increase.emit(old_val, physical)
	_schedule_update()
	
func decrease_physical():
	var old_val = physical
	physical -= 1
	if physical == MIN_PHYSICAL:
		physical = 1
	physical_decrease.emit(old_val, physical)
	_schedule_update()
	
func increase_emotional():
	var old_val = emotional
	emotional += 1
	if emotional == MAX_EMOTIONAL:
		emotional = 5
	emotional_increase.emit(old_val, emotional)
	_schedule_update()
	
func decrease_emotional():
	var old_val = emotional
	emotional -= 1
	if emotional == MIN_EMOTIONAL:
		emotional = 1
	emotional_decrease.emit(old_val, emotional)
	_schedule_update()
	
func add_food_eaten():
	foods_eaten_count += 1
	food_eaten.emit(foods_eaten_count)
	
	# Check for milestones
	if foods_eaten_count % 4 == 0:
		eating_milestone.emit(foods_eaten_count)
		# Increase physical and emotional by 1 every 4 foods
		increase_physical()
		increase_emotional()

		var make_bfast = get_tree().current_scene.find_child("make_bfast", true, false)
		if make_bfast and make_bfast.has_method("close_event"):
			make_bfast.close_event()
			print("make_bfast event closed")
		
		# Complete the eating task
		for i in range(TaskManager.active_tasks.size()):
			if TaskManager.active_tasks[i].text == "Eat apple \n slices.":
				TaskManager.complete_task(i)
				break  # Exit after finding and completing the task

func add_dust_cleaned():
	dust_cleaned_count += 1
	
	if dust_cleaned_count == 20:
		cleaning_milestone.emit(dust_cleaned_count)
		decrease_emotional()
		decrease_emotional()
		decrease_emotional()
		decrease_physical()
		decrease_physical()
		
		for i in range(TaskManager.active_tasks.size()):
			if TaskManager.active_tasks[i].text == "Vacuum \n the entire \n house.":
				TaskManager.complete_task(i)
				break  # Exit after finding and completing the task
		
