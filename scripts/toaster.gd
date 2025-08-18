extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
#@onready var sound_effect: AudioStreamPlayer3D = $sfx

var is_on = 0
var turn_off_minute: int = -1  # The game minute when device should turn off
var is_timer_active = false

func _ready():
	# Connect to time updates
	GlobalTime.time_updated.connect(_on_time_updated)

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if is_on == 0:
		anim_player.play("ON")
		is_on = 1
		
		# Calculate turn off time (10 game minutes from now)
		var current_time = GlobalTime.get_current_time()
		var current_total_minutes = (current_time.hour * 60) + current_time.minute
		if current_time.is_pm and current_time.hour != 12:
			current_total_minutes += 12 * 60
		elif not current_time.is_pm and current_time.hour == 12:
			current_total_minutes -= 12 * 60
		
		turn_off_minute = current_total_minutes + 10  # Add 10 game minutes
		is_timer_active = true
		
		print("Device turned ON. Will turn off in 10 game minutes")

func _on_time_updated(hour: int, minute: int, is_pm: bool, formatted_time: String):
	if not is_timer_active or is_on == 0:
		return
	
	# Calculate current total minutes
	var current_total_minutes = (hour * 60) + minute
	if is_pm and hour != 12:
		current_total_minutes += 12 * 60
	elif not is_pm and hour == 12:
		current_total_minutes -= 12 * 60
	
	# Check if 10 minutes have passed
	if current_total_minutes >= turn_off_minute:
		turn_off_device()

func turn_off_device():
	if is_on == 1:
		anim_player.play("DONE")  # Make sure you have an OFF animation
		is_on = 0
		is_timer_active = false
		print("Device turned OFF automatically after 10 minutes")
