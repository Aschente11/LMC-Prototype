extends Node3D
var xr_interface: XRInterface
@onready var environment_node = $WorldEnvironment
@onready var make_bfast_sfx = $wake_up
@onready var note_tutorial_sfx = $note_tutorial
@onready var kitchen_area = $bfast
var current_stimulation = 0

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
	
	call_deferred("check_initial_state")
	
	GlobalVar.stimulation_increase.connect(_on_stimulation_increase)
	GlobalVar.stimulation_decrease.connect(_on_stimulation_decrease)
	GlobalVar.eating_milestone.connect(_on_eating_milestone)

	kitchen_area.body_entered.connect(_on_kitchen_area_entered)

	# First sequence - breakfast
	var make_bfast_text = get_tree().get_first_node_in_group("make_bfast_text")
	make_bfast_text.visible = true
	make_bfast_sfx.play()
	
	# Connect to first audio finished to trigger second sequence
	make_bfast_sfx.finished.connect(_on_first_audio_finished)

# Kitchen area entered handler
func _on_kitchen_area_entered(body):
	if body.is_in_group("player"):
		kitchen_area.queue_free()

# Add this new function:
func _on_first_audio_finished():
	# Hide breakfast text
	var make_bfast_text = get_tree().get_first_node_in_group("make_bfast_text")
	make_bfast_text.visible = false
	
	# Show note tutorial
	var note_tutorial_text = get_tree().get_first_node_in_group("note_tutorial_text")
	note_tutorial_text.visible = true
	note_tutorial_sfx.play()
	
func check_initial_state() -> void:
	_on_stimulation_changed(GlobalVar.stimulation)

# Connect to the same signals as the smartwatch for consistency
func _on_stimulation_increase(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_decrease(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_changed(new_stimulation_value: int) -> void:
	pass
	
func _on_eating_milestone(milestone: int):
	var make_bfast_text = get_tree().get_first_node_in_group("make_bfast_text")
	make_bfast_text.visible = false
