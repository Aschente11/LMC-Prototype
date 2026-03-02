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
		
	
	TaskManager.initialize(2)
	TaskManager.tasks_completed.connect(_on_tasks_completed)
	
	GlobalTime.reset_time(3, 30, true)
	
	if GlobalTime.time_timer:
		GlobalTime.time_timer.paused = false
		GlobalTime.resume_time() 
	GlobalTime.connect("midnight_reached", _on_midnight_reached)
	
	GlobalVar.set_permanently_overstimulated()
	
	$"Cant calm down".play()
	await get_tree().create_timer(5.0).timeout
	$"Huffing sfx".play()
	
func _on_sleep_body_entered(body: Node3D) -> void:
	self.load_scene("res://scenes/lmc_day_end.tscn", "day_end")
	
	$sleep.visible = false
	$sleep.monitoring = false
	$sleep.monitorable = false

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
