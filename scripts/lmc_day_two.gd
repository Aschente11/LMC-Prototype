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
	
	GlobalTime.start_time()
	$"Event1 text2".visible = false

func _on_sleep_body_entered(body: Node3D) -> void:
	self.load_scene("res://scenes/lmc_day_end.tscn", "day_end")
	
	$sleep.visible = false
	$sleep.monitoring = false
	$sleep.monitorable = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_day_start_event_started() -> void:
	$"Event1 text".visible = false
	$"Event1 text2".visible = true
	print("WRITING ON BOARD EVENT ENDED")
