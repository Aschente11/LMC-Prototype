extends XRToolsSceneBase

var xr_interface: XRInterface

var anim_player
@onready var xr_player = $XROrigin3D

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

	TaskManager.initialize(2)
	TaskManager.tasks_completed.connect(_on_tasks_completed)
	
	GlobalTime.reset_time(3, 30, true)
	
	if GlobalTime.time_timer:
		GlobalTime.time_timer.paused = false
		GlobalTime.resume_time() 
	GlobalTime.connect("midnight_reached", _on_midnight_reached)
	
	$XROrigin3D.is_game_over.connect(restart_day) 
	GlobalVar.set_permanently_overstimulated()
	
	$"Cant calm down".play()
	await get_tree().create_timer(5.0).timeout
	$"Huffing sfx".play()
	
func restart_day():
	self.reset_scene()
	
func _on_sleep_body_entered(body: Node3D) -> void:
	self.load_scene("res://scenes/lmc_day_end.tscn", "day_end")
	
	$sleep.visible = false
	$sleep.monitoring = false
	$sleep.monitorable = false

func _randomize_effect(rand: int):
	if rand == -1:
		GlobalVar.decrease_emotional()
	elif rand == 1:
		GlobalVar.increase_emotional()

func teleport_player(marker):
	var pos
	
	var rng = RandomNumberGenerator.new()
	
	if marker == "bed":
		pos = $BedMarker.global_position
		print("teleported to bed")
		
	elif marker == "TVSet1":
		pos = $TVSetMarker1.global_position
		_randomize_effect(rng.randi_range(-1,1))
		print("teleported to TVSet1")
		
	elif marker == "TVSet2":
		pos = $TVSetMarker2.global_position
		_randomize_effect(rng.randi_range(-1,1))
		print("teleported to TVSet2")
	
	elif marker == "TVSet3":
		pos = $TVSetMarker3.global_position
		_randomize_effect(rng.randi_range(-1,1))
		print("teleported to TVSet3")
	
	elif marker == "Chair1":
		pos = $ChairMarker1.global_position
		GlobalVar.increase_emotional()
		print("teleported to Chair1")
	
	elif marker == "Chair2":
		pos = $ChairMarker2.global_position
		GlobalVar.increase_emotional()
		print("teleported to Chair2")
		
	elif marker == "Nap":
		pos = $BedMarker.global_position
		GlobalVar.increase_emotional()
		GlobalVar.increase_emotional()
		GlobalVar.increase_physical()
		GlobalVar.increase_physical()
		print("teleported to bed")
		
	xr_player.global_position = pos
	
	anim_player.play("blinking")
	
	await get_tree().create_timer(1).timeout
	
	anim_player.play("open_eyes")

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
