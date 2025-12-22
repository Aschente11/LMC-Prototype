extends XRToolsSceneBase

var xr_interface: XRInterface

var anim_player

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
		
	$WakingUpPlayer/XROrigin3D.current = true
	$WakingUpPlayer/XROrigin3D/XRCamera3D.current = true
	
	$XROrigin3D.current = false
	$XROrigin3D/XRCamera3D.current = false
	
	$unpacking.visible = false
	$unpacking.monitoring = false
	$unpacking.monitorable = false
	
	$sleep.visible = false
	$sleep.monitoring = false
	$sleep.monitorable = false
	
	$SleepViewport.visible = false
	
	$plushie/Sketchfab_Scene.is_crying.connect(teleport_player)
	
	TaskManager.initialize(0)
	
	GlobalTime.start_time(12, 30, true)
	GlobalVar.eating_milestone.connect(_on_eating_milestone)
	
	# QTE/Waking up scene
	handle_qte()
	
func handle_qte():
	$WakingUpPlayer/QTE.start_qte()
	
	if $Audio/Alarm.is_playing():
		$Audio/Alarm.stop()
	$Audio/Alarm.play()

func on_qte_fail():
	handle_qte()

func on_qte_success():
	$WakingUpPlayer/AnimationPlayer.play("Blinking")
	
	await get_tree().create_timer(5).timeout
	print("Changed Scene")
	
	# Change from QTE to actual player XROrigin and Camera
	if $XROrigin3D and $WakingUpPlayer:
		$XROrigin3D.set_global_position($InitialMarker.global_position)
		anim_player = $XROrigin3D.get_node("AnimationPlayer")
		
		$WakingUpPlayer/XROrigin3D.current = false
		$WakingUpPlayer/XROrigin3D/XRCamera3D.current = false
		
		$XROrigin3D.current = true
		$XROrigin3D/XRCamera3D.current = true
		
		remove_child($WakingUpPlayer)
		$WakingUpPlayer.queue_free()
		
	$Audio/Alarm.stop()
	
	$Audio/wake_up.play()
	
	# Connect to first audio finished to trigger second sequence
	$Audio/wake_up.finished.connect(_on_first_audio_finished)
	
# Only works the first time fsr :'[
func teleport_player(marker):
	var pos
	
	if marker == "bed":
		pos = $BedMarker.global_position
		print("teleported to bed")
		
	$XROrigin3D.global_position = pos
	
	anim_player.play("blinking")
	
	await get_tree().create_timer(1).timeout
	
	anim_player.play("open_eyes")

func _on_first_audio_finished():
	$Audio/note_tutorial.play()

func _on_eating_milestone(milestone: int):
	$Audio/need_unpack.play()

func _on_bfast_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.name == "XRToolsPlayerBody":
		$bfast.queue_free()

		$unpacking.visible = true
		$unpacking.monitoring = true
		$unpacking.monitorable = true

func _on_unpacking_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") or body.name == "XRToolsPlayerBody":
		$unpacking.queue_free()
		
		$sleep.visible = true
		$sleep.monitoring = true
		$sleep.monitorable = true

func _on_sleep_body_entered(body: Node3D) -> void:
	$SleepViewport.visible = true
	
func _on_journal_picked_up():
	for i in range(TaskManager.active_tasks.size()):
			if TaskManager.active_tasks[i].text == "Read journal.":
				TaskManager.active_tasks[i].done = true
				
func is_xr_class(name : String) -> bool:
	return name == "XRToolsSceneBase"
