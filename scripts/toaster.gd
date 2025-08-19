extends Node3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var on_sfx: AudioStreamPlayer3D = $"ON sfx"
@onready var done_sfx: AudioStreamPlayer3D = $"DONE sfx"

@onready var bread_detection_area: Area3D = $BreadDetectionArea
@onready var timer_circle = $TimerCircle3D

var is_on = 0
var turn_off_minute: int = -1  # The game minute when device should turn off
var is_timer_active = false
var has_bread = false  # Track if bread is present

func _ready():
	# Connect to time updates
	GlobalTime.time_updated.connect(_on_time_updated)
	
	# Connect bread detection signals
	#if bread_detection_area:
		#bread_detection_area.body_entered.connect(_on_bread_entered)
		#bread_detection_area.body_exited.connect(_on_bread_exited)

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
	anim_player.play("DONE")
	done_sfx.play()
	is_timer_active = false
	print("Device turned OFF automatically after 10 minutes")

# Bread detection functions
#func _on_bread_entered(body: Node3D):
	## Check if the entered body is bread (adjust the condition based on your bread object)
	#if body.has_method("is_bread") or body.is_in_group("bread") or body.name.contains("bread"):
		#has_bread = true
		#print("Bread detected!")
#
#func _on_bread_exited(body: Node3D):
	## Check if the exited body is bread
	#if body.has_method("is_bread") or body.is_in_group("bread") or body.name.contains("bread"):
		#has_bread = false
		#print("Bread removed!")

func _on_ois_wipe_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	print("Wipe action attempted")
	
	if is_on == 0:
		anim_player.play("ON")
		on_sfx.play()
		start_countdown()
		is_on = 1
		
		# Calculate turn off time (20 game minutes from now)
		var current_time = GlobalTime.get_current_time()
		var current_total_minutes = (current_time.hour * 60) + current_time.minute
		if current_time.is_pm and current_time.hour != 12:
			current_total_minutes += 12 * 60
		elif not current_time.is_pm and current_time.hour == 12:
			current_total_minutes -= 12 * 60
		
		turn_off_minute = current_total_minutes + 20  # Add 20 game minutes
		is_timer_active = true
		
		print("Device turned ON with bread present. Will turn off in 20 game minutes")
	
func start_countdown():
	timer_circle.start_timer(14.0)  # 60 second timer
