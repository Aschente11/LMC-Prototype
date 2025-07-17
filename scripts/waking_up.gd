extends Node3D

var xr_interface: XRInterface
@onready var alarm: AudioStreamPlayer3D = $Alarm

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
		
	await get_tree().create_timer(1).timeout

	$XRPlayer/QTE.start_qte()
	alarm.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func _on_wake_up_event_started() -> void:
	pass # Replace with function body.
