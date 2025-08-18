extends Node

# Signals for other scripts to listen to time changes
signal time_updated(hour: int, minute: int, is_pm: bool, formatted_time: String)
signal hour_changed(new_hour: int, is_pm: bool)
signal day_changed(is_pm: bool)

# Time variables
var current_hour: int = 7
var current_minute: int = 0
var is_pm: bool = false

# 7 seconds irl = 10 minutes game time
var time_timer: Timer

# Game day
var current_day: int = 1

func _ready():
	time_timer = Timer.new()
	time_timer.wait_time = 7.0  # 7 seconds irl = 10 minutes game time
	time_timer.autostart = true
	time_timer.timeout.connect(_on_time_update)
	add_child(time_timer)
	
	print("TimeManager initialized - Starting time: ", get_formatted_time())


func _on_time_update():
	var old_hour = current_hour
	var old_is_pm = is_pm
	
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
			
			# If we just switched to 12 PM, it's a new day
			if is_pm:
				current_day += 1
				day_changed.emit(is_pm)
	
	# MOVE THIS OUTSIDE THE IF BLOCK - Decrease physical EVERY 10 minutes
	print("Time update: ", get_formatted_time())
	GlobalVar.physical -= 0.1
	GlobalVar.physical = max(GlobalVar.physical, 0.0)  # Don't go below 0
	print("Physical decreased to: ", GlobalVar.physical)
	GlobalVar.physical_decrease.emit(GlobalVar.physical)
	
	# Emit signals for other scripts to react to
	var formatted_time = get_formatted_time()
	time_updated.emit(current_hour, current_minute, is_pm, formatted_time)
	
	# Emit hour change signal if hour changed
	if old_hour != current_hour or old_is_pm != is_pm:
		hour_changed.emit(current_hour, is_pm)

# Get formatted time string
func get_formatted_time() -> String:
	var hour_display = current_hour
	var minute_str = "%02d" % current_minute
	var period = "AM" if !is_pm else "PM"
	return "%d:%s %s" % [hour_display, minute_str, period]

# Function to set specific time
func set_time(hour: int, minute: int, pm: bool = false):
	current_hour = clamp(hour, 1, 12)
	current_minute = clamp(minute, 0, 59)
	is_pm = pm
	
	# Emit update signal
	var formatted_time = get_formatted_time()
	time_updated.emit(current_hour, current_minute, is_pm, formatted_time)

# Function to get current time as dictionary
func get_current_time() -> Dictionary:
	return {
		"hour": current_hour,
		"minute": current_minute,
		"is_pm": is_pm,
		"formatted": get_formatted_time(),
		"day": current_day
	}

# Get time in 24-hour format
func get_24_hour_format() -> Dictionary:
	var hour_24 = current_hour
	if is_pm and current_hour != 12:
		hour_24 += 12
	elif !is_pm and current_hour == 12:
		hour_24 = 0
		
	return {
		"hour": hour_24,
		"minute": current_minute,
		"formatted": "%02d:%02d" % [hour_24, current_minute]
	}

# Check if it's within a specific time range
func is_time_between(start_hour: int, start_minute: int, start_pm: bool, end_hour: int, end_minute: int, end_pm: bool) -> bool:
	var current_minutes = get_total_minutes()
	var start_minutes = convert_to_minutes(start_hour, start_minute, start_pm)
	var end_minutes = convert_to_minutes(end_hour, end_minute, end_pm)
	
	if start_minutes <= end_minutes:
		return current_minutes >= start_minutes and current_minutes <= end_minutes
	else:
		# Handle overnight ranges (e.g., 10 PM to 6 AM)
		return current_minutes >= start_minutes or current_minutes <= end_minutes

# Helper function to convert time to total minutes since midnight
func get_total_minutes() -> int:
	return convert_to_minutes(current_hour, current_minute, is_pm)

func convert_to_minutes(hour: int, minute: int, pm: bool) -> int:
	var total_hour = hour
	if pm and hour != 12:
		total_hour += 12
	elif !pm and hour == 12:
		total_hour = 0
	return (total_hour * 60) + minute

# Pause/Resume time
func pause_time():
	time_timer.paused = true

func resume_time():
	time_timer.paused = false

# Speed up or slow down time
func set_time_speed(multiplier: float):
	time_timer.wait_time = 7.0 / multiplier
