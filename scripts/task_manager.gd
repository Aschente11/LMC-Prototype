class_name TaskManager

extends Node3D

@export var max_active_tasks: int = 3
@export var prioritize_high_priority: bool = true
@export var show_priority_indicators: bool = true

@export var label_font: FontFile

var notebook_scene_node: Node3D
var task_pool: Array[Task] = []

var active_tasks: Array[Task] = []
var task_labels: Array[Label3D] = []
var priority_labels: Array[Label3D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_task_pool()
	if not %notebook:
		push_error("Could not find notebook for task manager!")
	else:
		notebook_scene_node = %notebook
	generate_new_tasks()
	display_tasks()


func initialize_task_pool():
	task_pool.append(Task.new("Make and have breakfast", Task.Priority.HIGH))
	task_pool.append(Task.new("Make and have lunch", Task.Priority.HIGH))
	task_pool.append(Task.new("Make and have dinner", Task.Priority.HIGH))
	task_pool.append(Task.new("Do urgent requirements", Task.Priority.HIGH))
	
	task_pool.append(Task.new("Have a snack", Task.Priority.MEDIUM))
	task_pool.append(Task.new("Respond to emails", Task.Priority.MEDIUM))
	task_pool.append(Task.new("Do homework due this week", Task.Priority.MEDIUM))
	task_pool.append(Task.new("Wash dishes", Task.Priority.MEDIUM))
	task_pool.append(Task.new("Do laundry", Task.Priority.MEDIUM))
	task_pool.append(Task.new("Organize clothes", Task.Priority.MEDIUM))
	
	task_pool.append(Task.new("Practice drawing fundamentals", Task.Priority.LOW))
	task_pool.append(Task.new("Organize handouts per course", Task.Priority.LOW))
	task_pool.append(Task.new("Vacuum the entire house", Task.Priority.LOW))
	task_pool.append(Task.new("Throw the trash", Task.Priority.LOW))
	task_pool.append(Task.new("Dust furniture", Task.Priority.LOW))
	task_pool.append(Task.new("Clean the bathroom", Task.Priority.LOW))


func generate_new_tasks():
	active_tasks.clear()
	
	var available_tasks = task_pool.duplicate()
	
	for i in range(min(max_active_tasks, available_tasks.size())):
		var selected_task: Task
		
		if prioritize_high_priority:
			selected_task =  select_weighted_random_task(available_tasks)
		else:
			var random_index = randi() % available_tasks.size()
			selected_task = available_tasks[random_index]
			
		active_tasks.append(selected_task)
		available_tasks.erase(selected_task)
		
	active_tasks.sort_custom(compare_task_priority)


func select_weighted_random_task(available_tasks: Array[Task]) -> Task:
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
	
func display_tasks():
	clear_task_display()
	
	for i in range(active_tasks.size()):
		create_task_label(active_tasks[i], i)


func create_task_label(task: Task, index: int):
	var label = Label3D.new()
	label.text = task.text
	label.font = label_font
	label.font_size = 36 
	label.pixel_size = 0.005
	
	label.position.y = 0.2
	label.position.x = -0.8 + (index * 0.4)
	#label.position.z = -0.05 - (index * 0.08)
	
	label.rotation_degrees.x = -90
	label.rotation_degrees.y = 90
	
	#label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	
	#var material = StandardMaterial3D.new()
	#material.albedo_color = task.priority_color
	#material.flags_unshaded = true
	
	#if task.priority == Task.Priority.HIGH:
	#	material.emission_enabled = true
	#	material.emission = task.priority_color * 0.3
		
	#label.material_override = material
	
	notebook_scene_node.add_child(label)
	task_labels.append(label)
	
	if show_priority_indicators:
		create_priority_indicator(task, index)
	print("Task label craeted for ", task.text)


func create_priority_indicator(task: Task, index: int):
	var priority_label = Label3D.new()
	priority_label.text = "[" + task.get_priority_text(task.priority) + "]"
	priority_label.font_size = 28  
	priority_label.pixel_size = 0.004  
	
	priority_label.position.y = 0.2
	priority_label.position.x = -0.6 + (index * 0.4)
	priority_label.position.z = -0.6
	
	priority_label.rotation_degrees.x = -90
	priority_label.rotation_degrees.y = 90
	
	priority_label.modulate = task.priority_color * 0.8  
	
	#priority_label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	
	#var material = StandardMaterial3D.new()
	#material.albedo_color = task.priority_color * 0.8  
	#material.flags_unshaded = true
	#priority_label.material_override = material
	
	notebook_scene_node.add_child(priority_label)
	priority_labels.append(priority_label)
	
	print("Priority label craeted for ", task.text)


func clear_task_display():
	for label in task_labels:
		if is_instance_valid(label):
			label.queue_free()
	task_labels.clear()
	
	for label in priority_labels:
		if is_instance_valid(label):
			label.queue_free()
	priority_labels.clear()


func complete_task(task_index: int):
	if task_index >= 0 and task_index < active_tasks.size():
		var completed_task = active_tasks[task_index]
		print("Task completed: ", completed_task.text, " [", completed_task.get_priority_text(completed_task.priority), "]")
		active_tasks.remove_at(task_index)
		
		add_random_task()
		
		display_tasks()


func add_random_task():
	if active_tasks.size() >= max_active_tasks:
		return
		
	var available_tasks: Array[Task] = []
	for task in task_pool:
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
	display_tasks()
	print("Tasks refreshed!")


func get_active_tasks() -> Array[Task]:
	return active_tasks.duplicate()


func get_tasks_by_priority(priority: Task.Priority) -> Array[Task]:
	var filtered_tasks: Array[Task] = []
	for task in active_tasks:
		if task.priority == priority:
			filtered_tasks.append(task)
	return filtered_tasks


func add_task_to_pool(task_text: String, priority: Task.Priority):
	var new_task = Task.new(task_text, priority)
	var task_exists = false
	
	for existing_task in task_pool:
		if existing_task.text == task_text:
			task_exists = true
			break
	
	if not task_exists:
		task_pool.append(new_task)
		print("Added new task to pool: ", task_text, " [", new_task.get_priority_text(priority), "]")


func remove_task_from_pool(task_text: String):
	for i in range(task_pool.size() - 1, -1, -1):
		if task_pool[i].text == task_text:
			task_pool.remove_at(i)
			print("Removed task from pool: ", task_text)
			break
	
	for i in range(active_tasks.size() - 1, -1, -1):
		if active_tasks[i].text == task_text:
			complete_task(i)
			break


func toggle_priority_weighting():
	prioritize_high_priority = !prioritize_high_priority
	print("Priority weighting: ", "ON" if prioritize_high_priority else "OFF")


func get_priority_stats() -> Dictionary:
	var stats = {
		Task.Priority.HIGH: 0,
		Task.Priority.MEDIUM: 0,
		Task.Priority.LOW: 0
	}
	
	for task in active_tasks:
		stats[task.priority] += 1
	
	return stats
