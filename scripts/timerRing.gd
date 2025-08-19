class_name TimerRing
extends Node2D

# Signal emitted when countdown finishes
signal countdown_finished

# Node references
@onready var texture_progress_bar: TextureProgressBar = $Control/TextureProgressBar
@onready var label_node: Label

# Timer variables
var countdown_duration: float = 0.0
var time_elapsed: float = 0.0
var is_counting: bool = false

func _ready():
	# Initialize progress bar
	if texture_progress_bar:
		texture_progress_bar.value = 0.0  # Start empty for fill-up effect
		texture_progress_bar.visible = false
	
	# Create optional time label
	create_time_label()

func _process(delta):
	if not is_counting:
		return
	
	time_elapsed += delta
	
	# Calculate progress (0.0 to 1.0)
	var progress = time_elapsed / countdown_duration
	
	if progress >= 1.0:
		# Timer finished
		progress = 1.0
		is_counting = false
		countdown_finished.emit()
		print("Countdown finished!")
	
	# Update progress bar (fills up as time progresses)
	if texture_progress_bar:
		texture_progress_bar.value = progress * 100.0
	
	# Update time display
	update_time_display()

func create_time_label():
	"""Create a label for displaying countdown time"""
	label_node = Label.new()
	label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Position in center of progress bar
	if texture_progress_bar:
		var bar_size = texture_progress_bar.size
		var bar_pos = texture_progress_bar.position
		label_node.position = Vector2(bar_pos.x + bar_size.x/2 - 30, bar_pos.y + bar_size.y/2 - 10)
		label_node.size = Vector2(60, 20)
	
	$Control.add_child(label_node)

func update_time_display():
	"""Update the countdown display"""
	if label_node:
		var remaining_time = countdown_duration - time_elapsed
		remaining_time = max(0.0, remaining_time)
		label_node.text = "%.1fs" % remaining_time

# PUBLIC METHODS - Call these from parent scenes

func start_countdown(duration_seconds: float):
	"""Start countdown timer - MAIN METHOD for parent scenes"""
	countdown_duration = duration_seconds
	time_elapsed = 0.0
	is_counting = true
	
	if texture_progress_bar:
		texture_progress_bar.visible = true
		texture_progress_bar.value = 0.0
	
	update_time_display()
	print("Starting %.1f second countdown" % duration_seconds)

func stop_countdown():
	"""Stop the countdown"""
	is_counting = false
	time_elapsed = 0.0
	
	if texture_progress_bar:
		texture_progress_bar.value = 0.0

func hide_timer():
	"""Hide the timer display"""
	if texture_progress_bar:
		texture_progress_bar.visible = false

func show_timer():
	"""Show the timer display"""
	if texture_progress_bar:
		texture_progress_bar.visible = true

func reset_countdown():
	"""Reset countdown to beginning"""
	time_elapsed = 0.0
	if texture_progress_bar:
		texture_progress_bar.value = 0.0
	update_time_display()

# GETTERS
func get_remaining_time() -> float:
	return max(0.0, countdown_duration - time_elapsed)

func get_progress_percent() -> float:
	if countdown_duration <= 0:
		return 0.0
	return (time_elapsed / countdown_duration) * 100.0

func is_countdown_active() -> bool:
	return is_counting
