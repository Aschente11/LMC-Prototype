extends Node

@onready var left_controller : XRController3D = $"../XROrigin3D/XRController3DLeft"
@onready var right_controller : XRController3D = $"../XROrigin3D/XRController3DRight"

# Source: https://www.youtube.com/watch?v=MfS73MPZBrM
enum QTE_STATES { START, RUNNING, FAILED, SUCCESS, STOPPED }
var QTE_STATUS : QTE_STATES = QTE_STATES.STOPPED
var QTE_LAYER : Node
var QTE_TIMER_LABEL: Label
var QTE_ACTION_TIMER_LABEL: Label
var QTE_LABEL : Label
var QTE_PLAYER_LABEL: Label
var QTE_FEEDBACK: Label

# VR Input tracking
var xr_interface: XRInterface
var by_button_pressed_last_frame: bool = false

# Debug variables
var debug_enabled: bool = true
var debug_label: Label

var POSSIBLE_ACTIONS : Array = [
	"by_button"
]
var CURRENT_QTE : Array = []
var PLAYER_QTE : Array = []
var QTE_SIZE : int = 4
var QTE_MAX_SIZE : int = 8
var QTE_INCREMENTER : int = 0
var QTE_TIME_LIMIT : float = 8 #seconds to finish the qte
var QTE_ACTION_TIME_LIMIT : float = 2 #seconds between the actions
var QTE_TIMER : float = 8
var QTE_ACTION_TIMER : float = 2
signal success_qte
signal failed_qte

func _ready() -> void:
	QTE_LAYER = %QTE_LAYER
	
	# Initialize VR interface
	xr_interface = XRServer.find_interface("OpenXR")
	if not xr_interface:
		xr_interface = XRServer.find_interface("OpenVR")
	
	if xr_interface:
		print("XR Interface found: ", xr_interface.get_name())
		# Make sure the interface is initialized
		if not xr_interface.is_initialized():
			xr_interface.initialize()
	else:
		print("No XR interface found!")
	
	
	if not left_controller:
		print("Left controller not found!")
	if not right_controller:
		print("Right controller not found!")
	
	# Create debug label if debugging is enabled
	if debug_enabled:
		create_debug_label()

# Fixed VR button checking - ONLY for debug display, no input handling
func check_vr_button_pressed(button_name: String) -> bool:
	if not xr_interface or not xr_interface.is_initialized():
		return false
	
	var button_pressed = false
	var left_pressed = false
	var right_pressed = false
	
	# Map the action name to actual OpenXR button names
	var actual_button_name = ""
	match button_name:
		"by_button":
			actual_button_name = "by_button"  # This should match your OpenXR action map
		_:
			actual_button_name = button_name
	
	# Check both controllers for the button
	if left_controller:
		left_pressed = left_controller.is_button_pressed(actual_button_name)
		button_pressed = left_pressed
	
	if right_controller:
		right_pressed = right_controller.is_button_pressed(actual_button_name)
		if not button_pressed:
			button_pressed = right_pressed
	
	# Update debug info ONLY
	if debug_enabled and debug_label:
		var debug_text = "VR Button Debug:\n"
		debug_text += "Button: " + button_name + "\n"
		debug_text += "Actual Button: " + actual_button_name + "\n"
		debug_text += "Left Controller: " + ("PRESSED" if left_pressed else "NOT PRESSED") + "\n"
		debug_text += "Right Controller: " + ("PRESSED" if right_pressed else "NOT PRESSED") + "\n"
		debug_text += "Overall: " + ("PRESSED" if button_pressed else "NOT PRESSED") + "\n"
		debug_text += "XR Interface: " + (xr_interface.get_name() if xr_interface else "NONE") + "\n"
		debug_text += "XR Initialized: " + ("YES" if xr_interface and xr_interface.is_initialized() else "NO") + "\n"
		debug_text += "Left Controller Found: " + ("YES" if left_controller else "NO") + "\n"
		debug_text += "Right Controller Found: " + ("YES" if right_controller else "NO")
		debug_label.text = debug_text
	
	return button_pressed

func is_vr_button_just_pressed(button_name: String) -> bool:
	var current_pressed = check_vr_button_pressed(button_name)
	var just_pressed = current_pressed and not by_button_pressed_last_frame
	by_button_pressed_last_frame = current_pressed
	
	# Debug output for just pressed events
	if debug_enabled and just_pressed:
		print("VR Button JUST PRESSED: ", button_name)
	
	return just_pressed

func create_debug_label() -> void:
	# Create a debug label that shows VR button status
	debug_label = Label.new()
	debug_label.name = "VRDebugLabel"
	debug_label.position = Vector2(10, 10)
	debug_label.size = Vector2(400, 300)
	debug_label.add_theme_color_override("font_color", Color.WHITE)
	debug_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	debug_label.add_theme_constant_override("shadow_offset_x", 2)
	debug_label.add_theme_constant_override("shadow_offset_y", 2)
	debug_label.z_index = 1000  # Make sure it's on top
	
	# Add to the scene tree
	get_tree().root.add_child(debug_label)
	print("Debug label created and added to scene")

func toggle_debug() -> void:
	debug_enabled = !debug_enabled
	if debug_enabled:
		if not debug_label:
			create_debug_label()
		else:
			debug_label.visible = true
	else:
		if debug_label:
			debug_label.visible = false

# REMOVED: _input function - we'll handle input in _process instead

# Separate function to handle QTE input logic
func handle_qte_input() -> void:
	if PLAYER_QTE.size() < CURRENT_QTE.size():
		print("QTE Input registered - Player action: ", PLAYER_QTE.size() + 1)
		PLAYER_QTE.push_back(CURRENT_QTE[PLAYER_QTE.size()])
		print("Player QTE: ", PLAYER_QTE)
		print("Current QTE: ", CURRENT_QTE)
		
		if QTE_PLAYER_LABEL:
			QTE_PLAYER_LABEL.text = str(PLAYER_QTE)
		
		QTE_ACTION_TIMER = QTE_ACTION_TIME_LIMIT
		
		# Check if QTE is complete
		if PLAYER_QTE == CURRENT_QTE:
			print("Success")
			QTE_STATUS = QTE_STATES.SUCCESS
			QTE_INCREMENTER += 1
			if QTE_INCREMENTER > QTE_MAX_SIZE:
				QTE_INCREMENTER = QTE_MAX_SIZE
			QTE_SIZE = QTE_SIZE + floor(QTE_INCREMENTER / 2)
			success_qte.emit()
			if QTE_LAYER:
				if QTE_FEEDBACK:
					QTE_FEEDBACK.text = "YIPPIE"
				await get_tree().create_timer(1).timeout
				var Instance = get_tree().root.find_child("QTE_LAYER", true, false)
				if Instance:
					Instance.queue_free()
				stop_qte()
	
func _process(delta:float) -> void:
	# Update debug info continuously (but don't handle input here)
	if debug_enabled:
		check_vr_button_pressed("by_button")  # Only for debug display now
	
	# Handle VR input ONLY during QTE
	if QTE_STATUS == QTE_STATES.RUNNING:
		# Use the "just pressed" logic to prevent multiple inputs
		if is_vr_button_just_pressed("by_button"):
			handle_qte_input()
	
	if QTE_STATUS == QTE_STATES.RUNNING:
		QTE_TIMER -= delta
		QTE_ACTION_TIMER -= delta
		if QTE_TIMER_LABEL:
			QTE_TIMER_LABEL.text = "QTE TIMER: " + str(floor(QTE_TIMER * 100) / 100)
		if QTE_ACTION_TIMER_LABEL:
			QTE_ACTION_TIMER_LABEL.text = "QTE NEXT ACTION: " + str(floor(QTE_ACTION_TIMER * 100) / 100)
		if PLAYER_QTE != CURRENT_QTE && (QTE_TIMER <= 0 || QTE_ACTION_TIMER <= 0):
			print("FAILED!!! :'(")
			QTE_STATUS = QTE_STATES.FAILED
			if QTE_FEEDBACK:
				QTE_FEEDBACK.text = "FAILED!! :("
			stop_qte()
			
func stop_qte() -> void:
	await get_tree().create_timer(2).timeout
	QTE_STATUS = QTE_STATES.STOPPED
	failed_qte.emit()
			
func start_qte() -> void:
	if QTE_STATUS != QTE_STATES.STOPPED:
		return
	
	if QTE_LAYER:
		var Instance = QTE_LAYER
		QTE_TIMER_LABEL = Instance.find_child("QTE_TIMER", true, false)
		QTE_ACTION_TIMER_LABEL = Instance.find_child("QTE_ACTION_TIMER", true, false)
		QTE_PLAYER_LABEL = Instance.find_child("QTE_PLAYER", true, false)
		QTE_LABEL = Instance.find_child("QTE", true, false)
		QTE_FEEDBACK = Instance.find_child("QTE_FEEDBACK", true, false)
		print("QTE initialized")
		
	QTE_STATUS = QTE_STATES.START
	QTE_TIMER = QTE_TIME_LIMIT
	QTE_ACTION_TIMER = QTE_ACTION_TIME_LIMIT
	CURRENT_QTE = []
	PLAYER_QTE = []
	by_button_pressed_last_frame = false  # Reset button state
	
	for length in QTE_SIZE:
		CURRENT_QTE.push_back(POSSIBLE_ACTIONS.pick_random())
	
	if QTE_LABEL:
		QTE_LABEL.text = str(CURRENT_QTE)
		
	if QTE_FEEDBACK:
		QTE_FEEDBACK.text = "WAKE ME UP:(("
		
	await get_tree().create_timer(1).timeout
	
	if QTE_FEEDBACK:
		QTE_FEEDBACK.text = "'B'"
		
	QTE_STATUS = QTE_STATES.RUNNING
