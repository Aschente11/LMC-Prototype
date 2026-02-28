extends XRToolsSceneBase

var xr_interface: XRInterface

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
		
	
	TaskManager.initialize(1)
	TaskManager.tasks_completed.connect(_on_tasks_completed)
	
	#GlobalTime.start_time()
	GlobalTime.reset_time(7, 0, false)
	GlobalTime.connect("midnight_reached", _on_midnight_reached)

	GlobalVar.default_state()
	
	$"Event1 text2".visible = false
	await get_tree().create_timer(2.0).timeout
	$"Event 1".play()
	
	$sleep.visible = false
	$sleep.monitoring = false
	$sleep.monitorable = false
	
	$"XROrigin3D/XRCamera3D/LOST IN THOUGHTS".visible = false

	
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
