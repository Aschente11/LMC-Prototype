extends Node3D

@onready var time_label: Label = $Time/SubViewport/Control/Label
@onready var subviewport: SubViewport = $Time/SubViewport

# Time variables
var current_hour: int = 7
var current_minute: int = 0
var is_pm: bool = false

# Timer for updating time (7 seconds real time = 10 minutes game time)
var time_timer: Timer

func _ready():
	
	# Create and configure the timer
	time_timer = Timer.new()
	time_timer.wait_time = 7.0  # 7 seconds in real life
	time_timer.autostart = true
	time_timer.timeout.connect(_on_time_update)
	add_child(time_timer)
	
	# Initialize the display
	_update_time_display()

func _on_time_update():
	# Add 10 minutes to current time
	current_minute += 10
	
	# Handle minute overflow
	if current_minute >= 60:
		current_minute = 0
		current_hour += 1
		
		# Handle hour overflow and AM/PM switching
		if current_hour > 12:
			current_hour = 1
		elif current_hour == 12:
			is_pm = !is_pm
	
	_update_time_display()

func _update_time_display():
	var hour_display = current_hour
	var minute_str = "%02d" % current_minute
	var period = "AM" if !is_pm else "PM"
	
	var time_string = "%d:%s %s" % [hour_display, minute_str, period]
	time_label.text = time_string

# Optional: Function to set specific time
func set_time(hour: int, minute: int, pm: bool = false):
	current_hour = clamp(hour, 1, 12)
	current_minute = clamp(minute, 0, 59)
	is_pm = pm
	_update_time_display()

# Optional: Function to get current time as dictionary
func get_current_time() -> Dictionary:
	return {
		"hour": current_hour,
		"minute": current_minute,
		"is_pm": is_pm,
		"formatted": time_label.text
	}
