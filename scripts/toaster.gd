extends XRToolsPickable

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var on_sfx: AudioStreamPlayer3D = $"ON sfx"
@onready var done_sfx: AudioStreamPlayer3D = $"DONE sfx"
@onready var bread_detection_area: Area3D = $BreadDetectionArea
@onready var timer_ring = $SubViewport/TimerRing

var is_on = 0
var is_timer_active = false
var has_bread = false

# Timer duration
var countdown_seconds: float = 14.0

func _ready():
	# Connect timer ring signal
	if timer_ring:
		timer_ring.countdown_finished.connect(_on_countdown_finished)
	
	# Connect bread detection signals (if needed)
	#if bread_detection_area:
		#bread_detection_area.body_entered.connect(_on_bread_entered)
		#bread_detection_area.body_exited.connect(_on_bread_exited)

func _on_countdown_finished():
	turn_off_device()

func turn_off_device():
	anim_player.play("DONE")
	done_sfx.play()
	is_timer_active = false
	is_on = 0
	
	# Hide timer ring
	if timer_ring:
		timer_ring.hide_timer()
	
	print("Toaster turned OFF after countdown")

func _on_ois_wipe_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	print("Wipe action attempted")
	
	if is_on == 0:
		anim_player.play("ON")
		on_sfx.play()
		is_on = 1
		is_timer_active = true
		
		# Start the 14-second countdown timer
		if timer_ring:
			timer_ring.start_countdown(countdown_seconds)
		
		print("Toaster turned ON. 14-second countdown started!")

# Utility methods
func set_countdown_duration(seconds: float):
	"""Change countdown duration"""
	countdown_seconds = seconds

func get_remaining_time() -> float:
	"""Get remaining countdown time"""
	if timer_ring:
		return timer_ring.get_remaining_time()
	return 0.0

# Bread detection functions (uncomment if needed)
#func _on_bread_entered(body: Node3D):
	#if body.has_method("is_bread") or body.is_in_group("bread") or body.name.contains("bread"):
		#has_bread = true
		#print("Bread detected!")

#func _on_bread_exited(body: Node3D):
	#if body.has_method("is_bread") or body.is_in_group("bread") or body.name.contains("bread"):
		#has_bread = false
		#print("Bread removed!")
