extends Node3D
var xr_interface: XRInterface

@onready var anim_player = $AnimationPlayer

@onready var xrplayer = $XRPlayer
@onready var xrtools_player_body = $XRPlayer/XROrigin3D/XRToolsPlayerBody
@onready var left_controller = $XRPlayer/XROrigin3D/XRController3DLeft
@onready var right_controller = $XRPlayer/XROrigin3D/XRController3DRight
@onready var main_origin3d = $XRPlayer/XROrigin3D
@onready var main_camera = $XRPlayer/XROrigin3D/XRCamera3D

@onready var sofa1_node = $sofa1_origin
@onready var sofa1_origin3d = $sofa1_origin/XROrigin3D
@onready var sofa1_camera = $sofa1_origin/XROrigin3D/XRCamera3D

@onready var sofa1 = $sit

# 7 seconds irl = 10 minutes game time
var time_timer: Timer

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
		
	main_origin3d.current = true
	main_camera.current = true
	sofa1_origin3d.current = false
	sofa1_camera.current = false
	
	GlobalTime.start_time()
	
	anim_player.play("daynightcycle")
	
func sit_down():
	GlobalVar.decrease_stimulation()
	
func _on_sit_body_entered(body):
	if body.is_in_group("player") or body.name == "XRToolsPlayerBody":
		time_timer = Timer.new()
		time_timer.wait_time = 7.0  # 7 seconds irl = 10 minutes game time
		time_timer.autostart = true
		time_timer.timeout.connect(sit_down)
		add_child(time_timer)
		
		sofa1.visible = false
		
		main_origin3d.current = false
		sofa1_origin3d.current = true
		
		main_camera.current = false
		sofa1_camera.current = true
		
		xrplayer.visible = false
		
		#xrplayer.remove_child(xrtools_player_body)
		#xrplayer.remove_child(left_controller)
		#xrplayer.remove_child(right_controller)
		#
		##tried adding child under origin3d, did not work
		#sofa1_node.add_child(xrtools_player_body)
		#sofa1_node.add_child(left_controller)
		#sofa1_node.add_child(right_controller)
		#
		#var new_pos = sofa1_node.global_position
		#xrtools_player_body.global_position = new_pos
		#left_controller.global_position = new_pos
		#right_controller.global_position = new_pos
		#left_controller.position.y = 0.200
		#right_controller.position.y = 0.200


func _on_sit_body_exited(body):
	if body.is_in_group("player") or body.name == "XRToolsPlayerBody":
		sofa1.visible = true
		xrplayer.visible = true
		time_timer.stop()
		remove_child(time_timer)
