extends Node3D

@export var prioritize_high_priority: bool = true
@export var show_priority_indicators: bool = true

var all_tasks: Array[Array] = [[], [], []]
@export var max_active_tasks: Array[int] = [2, 3, 3]
var current_day: int = 0
var completed_tasks: int = 0
var total_completed_tasks: int = 0

var active_tasks: Array[Task] = []

var current_task_index: int = 0
var current_task_assigned: bool = false

# Called when the node enters the scene tree for the first time.
func initialize(day: int):
	current_day = day
	completed_tasks = 0
	active_tasks.clear()
	initialize_task_pool()
	generate_new_tasks()

func initialize_task_pool():
	all_tasks[0].append(Task.new("Read journal.", Task.Priority.LOW))
	all_tasks[0].append(Task.new("Eat apple \n slices.", Task.Priority.MEDIUM))
	
	all_tasks[1].append(Task.new("Make and \n eat pancakes.", Task.Priority.HIGH))
	#all_tasks[1].append(Task.new("Make and \n eat a ham \n sandwich.", Task.Priority.MEDIUM))
	#all_tasks[1].append(Task.new("Make and \n eat a peanut \n butter sandwich.", Task.Priority.MEDIUM))
	all_tasks[1].append(Task.new("Eat apple \n slices.", Task.Priority.MEDIUM))
	all_tasks[1].append(Task.new("Continue \n writing \n essay.", Task.Priority.HIGH))
	all_tasks[1].append(Task.new("Practice \n painting", Task.Priority.HIGH))
	all_tasks[1].append(Task.new("Reread Art \n notes.", Task.Priority.LOW))
	
	all_tasks[2].append(Task.new("Wash dishes.", Task.Priority.MEDIUM))
	all_tasks[2].append(Task.new("Do laundry.", Task.Priority.MEDIUM))
	all_tasks[2].append(Task.new("Organize \n clothes.", Task.Priority.MEDIUM))
	all_tasks[2].append(Task.new("Vacuum \n the entire \n house.", Task.Priority.MEDIUM))
	all_tasks[2].append(Task.new("Clean the \n bathroom.", Task.Priority.LOW))

func generate_new_tasks():
	var available_tasks = all_tasks[current_day].duplicate()
	
	for i in range(min(max_active_tasks[current_day], available_tasks.size())):
		var selected_task: Task
		
		if prioritize_high_priority:
			selected_task =  select_weighted_random_task(available_tasks)
		else:
			var random_index = randi() % available_tasks.size()
			selected_task = available_tasks[random_index]
			
		active_tasks.append(selected_task)
		available_tasks.erase(selected_task)
		
	active_tasks.sort_custom(compare_task_priority)


func select_weighted_random_task(available_tasks: Array) -> Task:
	var weighted_tasks: Array[Task] = []
	
	for task in available_tasks:
		var weight = task.get_priority_weight(task.priority)
		for i in range(weight):
			weighted_tasks.append(task)
			
	if weighted_tasks.size() > 0:
		var random_index = randi() % weighted_tasks.size()
		return weighted_tasks[random_index]
	else:
		return available_tasks[0]


func compare_task_priority(a: Task, b: Task) -> bool:
	return a.priority > b.priority
	
func complete_task(task_index: int):
	if task_index >= 0 and task_index < active_tasks.size():
		var completed_task = active_tasks[task_index]
		completed_task.priority = Task.Priority.DONE
		print("Task completed: ", completed_task.text, " [", completed_task.get_priority_text(completed_task.priority), "]")
		
		completed_tasks += 1
		total_completed_tasks += 1
		#active_tasks.remove_at(task_index)
		
		#add_random_task()

func add_random_task():
	if active_tasks.size() >= max_active_tasks[current_day]:
		return
		
	var available_tasks: Array[Task] = []
	for task in all_tasks[current_day]:
		var is_active = false
		for active_task in active_tasks:
			if active_task.text == task.text:
				is_active = true
				break
		if not is_active:
			available_tasks.append(task)
				
	if available_tasks.size() > 0:
		var selected_task: Task
		if prioritize_high_priority:
			selected_task = select_weighted_random_task(available_tasks)
		else:
			var random_index = randi() % available_tasks.size()
			selected_task = available_tasks[random_index]
		
		active_tasks.append(selected_task)
		
		active_tasks.sort_custom(compare_task_priority)


func refresh_all_tasks():
	generate_new_tasks()
	print("Tasks refreshed!")


func get_active_tasks() -> Array[Task]:
	return active_tasks.duplicate()


func get_tasks_by_priority(priority: Task.Priority) -> Array[Task]:
	var filtered_tasks: Array[Task] = []
	for task in active_tasks:
		if task.priority == priority:
			filtered_tasks.append(task)
	return filtered_tasks


#func add_task_to_pool(task_text: String, priority: Task.Priority):
	#var new_task = Task.new(task_text, priority)
	#var task_exists = false
	#
	#for existing_task in all_tasks[current_day]:
		#if existing_task.text == task_text:
			#task_exists = true
			#break
	#
	#if not task_exists:
		#task_pool.append(new_task)
		#print("Added new task to pool: ", task_text, " [", new_task.get_priority_text(priority), "]")
#
#
#func remove_task_from_pool(task_text: String):
	#for i in range(task_pool.size() - 1, -1, -1):
		#if task_pool[i].text == task_text:
			#task_pool.remove_at(i)
			#print("Removed task from pool: ", task_text)
			#break
	#
	#for i in range(active_tasks.size() - 1, -1, -1):
		#if active_tasks[i].text == task_text:
			#complete_task(i)
			#break


func toggle_priority_weighting():
	prioritize_high_priority = !prioritize_high_priority
	print("Priority weighting: ", "ON" if prioritize_high_priority else "OFF")

# Called by a Post-it when it wants to get something to write
func request_task() -> String:
	if current_task_index >= active_tasks.size():
		return ""  # no more tasks
	# Only give text if it's not already being written on
	if not current_task_assigned:
		current_task_assigned = true
		return active_tasks[current_task_index].text
	else:
		return ""  # someone is still writing this one
		
# Called when a Post-it is finished being written
func mark_current_done():
	if current_task_index < active_tasks.size():
		current_task_index += 1
		
		if current_task_index == 2:
			$"../../Events/write_tasks"._on_writing_done()
	current_task_assigned = false


func get_priority_stats() -> Dictionary:
	var stats = {
		Task.Priority.HIGH: 0,
		Task.Priority.MEDIUM: 0,
		Task.Priority.LOW: 0
	}
	
	for task in active_tasks:
		stats[task.priority] += 1
	
	return stats
