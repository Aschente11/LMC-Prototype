extends XRToolsSceneBase

var xr_interface: XRInterface

var anim_player
@onready var xr_player = $XROrigin3D

enum Hand { LEFT, RIGHT }
@onready var left_watch = $XROrigin3D/LeftHand/smartwatch
@onready var right_watch = $XROrigin3D/RightHand/smartwatch
@onready var watch_display = $smartwatch

# Called when the node enters the scene tree for the first time.
func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully!")
		
		#Turn-off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		#Change our main viewport output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected.")
		
	anim_player = xr_player.get_node("AnimationPlayer")
	
	TaskManager.initialize(1)
	TaskManager.tasks_completed.connect(_on_tasks_completed)
	
	GlobalTime.reset_time(7, 0, false)
	
	if GlobalTime.time_timer:
		GlobalTime.time_timer.paused = false
		GlobalTime.resume_time() 
	GlobalTime.connect("midnight_reached", _on_midnight_reached)

	GlobalVar.default_state()
	
	$XROrigin3D.is_game_over.connect(restart_day) 
	$plushie/Sketchfab_Scene.is_crying.connect(teleport_player)
	
	$"Event1 text2".visible = false
	await get_tree().create_timer(2.0).timeout
	$"Event 1".play()
	
	#$sleep.visible = false
	#$sleep.monitoring = false
	#$sleep.monitorable = false
	
	$"XROrigin3D/XRCamera3D/LOST IN THOUGHTS".visible = false
	
func restart_day():
	self.reset_scene()
	
func _on_sleep_body_entered(body: Node3D) -> void:
	var root_scene = get_tree().current_scene
	root_scene.load_scene("res://scenes/lmc_day_end.tscn", "day_end")
	
	$sleep.visible = false
	$sleep.monitoring = false
	$sleep.monitorable = false
	
func _on_day_start_event_started() -> void:
	$"Event1 text".visible = false
	$"Event1 text2".visible = true
	$"Event 2".play()

	print("WRITING ON BOARD EVENT ENDED")

func _on_midnight_reached():
	print("Midnight! Loading day end scene from main scene...")
	var root_scene = get_tree().current_scene
	root_scene.load_scene("res://scenes/lmc_day_end.tscn", "day_end")

func _on_tasks_completed(total_completed: int):
	print("Tasks completed: ", total_completed)
	if total_completed >= 3:
		$sleep.visible = true
		$sleep.monitoring = true
		$sleep.monitorable = true

func _randomize_effect(rand: int):
	if rand == -1:
		GlobalVar.decrease_emotional()
	elif rand == 1:
		GlobalVar.increase_emotional()

func teleport_player(marker):
	var pos
	var time_mult = 1.0
	
	var rng = RandomNumberGenerator.new()
	
	if marker == "bed":
		pos = $BedMarker.global_position
		time_mult = 2.0
		print("teleported to bed")
		
	elif marker == "TVSet1":
		pos = $TVSetMarker1.global_position
		time_mult = 2.0
		_randomize_effect(rng.randi_range(-1,1))
		print("teleported to TVSet1")
		
	elif marker == "TVSet2":
		pos = $TVSetMarker2.global_position
		time_mult = 2.0
		_randomize_effect(rng.randi_range(-1,1))
		print("teleported to TVSet2")
	
	elif marker == "TVSet3":
		pos = $TVSetMarker3.global_position
		time_mult = 2.0
		_randomize_effect(rng.randi_range(-1,1))
		print("teleported to TVSet3")
	
	elif marker == "Chair1":
		pos = $ChairMarker1.global_position
		time_mult = 2.0
		GlobalVar.increase_emotional()
		print("teleported to Chair1")
	
	elif marker == "Chair2":
		pos = $ChairMarker2.global_position
		time_mult = 2.0
		GlobalVar.increase_emotional()
		print("teleported to Chair2")
		
	elif marker == "Nap":
		pos = $BedMarker.global_position
		time_mult = 4.0
		GlobalVar.increase_emotional()
		GlobalVar.increase_emotional()
		GlobalVar.increase_physical()
		GlobalVar.increase_physical()
		print("teleported to bed")
		
	xr_player.global_position = pos
	
	GlobalTime.set_time_speed(time_mult)
	
	anim_player.play("blinking")
	
	await get_tree().create_timer(5.0/time_mult).timeout
	
	anim_player.play("open_eyes")
	
	GlobalTime.set_time_speed(1.0)

func equip_watch(hand: Hand) -> void:
	watch_display.visible = false
	left_watch.visible = hand == Hand.LEFT
	right_watch.visible = hand == Hand.RIGHT


func _on_wear_watch_button_left_button_pressed() -> void:
	equip_watch(Hand.LEFT)


func _on_wear_watch_button_2_right_button_pressed() -> void:
	equip_watch(Hand.RIGHT)
