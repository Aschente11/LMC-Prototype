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
		
	remove_child(xr_player)
	
	$WakingUpPlayer/XROrigin3D.current = true
	$WakingUpPlayer/XROrigin3D/XRCamera3D.current = true
	

	#$sleep.visible = false
	#$sleep.monitoring = false
	#$sleep.monitorable = false
	
	$SleepViewport.visible = false
	
	$plushie/Sketchfab_Scene.is_crying.connect(teleport_player)
	
	TaskManager.initialize(0)
	
	GlobalTime.start_time(12, 30, true)
	
	# QTE/Waking up scene
	handle_qte()
	$"Event2 text".visible = false
	$"Event3 text".visible = false
	
	GlobalVar.default_state()
	
func handle_qte():
	$WakingUpPlayer/QTE.start_qte()
	
	if $Audio/Alarm.is_playing():
		$Audio/Alarm.stop()
	$Audio/Alarm.play()

func on_qte_fail():
	handle_qte()

func on_qte_success():
	$WakingUpPlayer/AnimationPlayer.play("Blinking")
	
	add_child(xr_player)
	xr_player.visible = false
	
	await get_tree().create_timer(5).timeout
	print("Changed Scene")
	
	# Change from QTE to actual player XROrigin and Camera
	if $WakingUpPlayer:
		xr_player.visible = true
		xr_player.set_global_position($InitialMarker.global_position)
		$XROrigin3D/XRToolsPlayerBody.set_global_position($InitialMarker.global_position)
		$XROrigin3D/XRToolsPlayerBody.enabled = true
		
		anim_player = xr_player.get_node("AnimationPlayer")
		
		$WakingUpPlayer/XROrigin3D.current = false
		$WakingUpPlayer/XROrigin3D/XRCamera3D.current = false
		
		xr_player.current = true
		$XROrigin3D/XRCamera3D.current = true
		
		$WakingUpPlayer.queue_free()
		print("Changed player")
		
	$Audio/Alarm.stop()
	
	$Audio/wake_up.play()
	await get_tree().create_timer(9.0).timeout
	$Audio/note_tutorial.play()
	
	
# Only works the first time fsr :'[
func teleport_player(marker):
	var pos
	
	if marker == "bed":
		pos = $BedMarker.global_position
		print("teleported to bed")
		
	xr_player.global_position = pos
	
	anim_player.play("blinking")
	
	await get_tree().create_timer(1).timeout
	
	anim_player.play("open_eyes")

func is_xr_class(name : String) -> bool:
	return name == "XRToolsSceneBase" or super(name)

func _on_bfast_body_entered(body: Node3D) -> void:
	
	$bfast.visible = false
	$bfast.monitoring = false
	$bfast.monitorable = false


func _on_sleep_body_entered(body: Node3D) -> void:
	$Audio/sleep.play()
	#$sleep.visible = false
	#$sleep.monitoring = false
	#$sleep.monitorable = false
	$"Event3 text".visible = true
	self.load_scene("res://scenes/lmc_day_end.tscn", "day_end")

func _on_make_bfast_event_started() -> void:
	$"Event1 text".visible = false
	$Audio/notes_done.play()

func _on_goodnight_event_started() -> void:
	$"Event2 text".visible =true
	$Audio/burp.play()
	$sleep.visible = true
	await get_tree().create_timer(3.5).timeout
	$sleep.monitoring = true
	$sleep.monitorable = true


func equip_watch(hand: Hand) -> void:
	watch_display.visible = false
	left_watch.visible = hand == Hand.LEFT
	right_watch.visible = hand == Hand.RIGHT


func _on_wear_watch_button_left_button_pressed() -> void:
	equip_watch(Hand.LEFT)


func _on_wear_watch_button_2_right_button_pressed() -> void:
	equip_watch(Hand.RIGHT)
