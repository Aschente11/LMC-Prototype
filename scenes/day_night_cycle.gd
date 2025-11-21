extends Node3D

# Reference to your AnimationPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Adjust path to your AnimationPlayer

# TimeManager reference
var time_manager

# Your animation name (adjust to match your animation name)
var animation_name: String = "dayandnight"  # Change this to your animation's name

# Total animation length in seconds (your current animation is 10 seconds)
var animation_length: float = 10.0

func _ready():
	# Get reference to GlobalTime autoload
	time_manager = GlobalTime
	
	# Make sure animation doesn't autoplay
	animation_player.stop()
	
	# Calculate the correct starting position
	var total_minutes = time_manager.convert_to_minutes(
		time_manager.current_hour, 
		time_manager.current_minute, 
		time_manager.is_pm
	)
	var day_progress = float(total_minutes) / 1440.0  # 1440 minutes in a day
	var start_position = day_progress * animation_length
	
	# Set the animation to the correct position and play
	animation_player.play("daynightcycle")
	animation_player.seek(5.5)
	
	# Set the animation speed to match the time progression
	# 1 full day (1440 minutes) should take: 1440 / 10 = 144 intervals of 7 seconds = 1008 seconds
	# Animation is 10 seconds, so speed = 10 / 1008
	var full_day_duration = (1440.0 / 10.0) * 7.0  # Total seconds for a full day
	animation_player.speed_scale = animation_length / full_day_duration
	
	print("Day/Night cycle synced with GlobalTime")
	print("Animation speed: ", animation_player.speed_scale)
	print("Starting at position: ", start_position, " (", time_manager.get_formatted_time(), ")")
