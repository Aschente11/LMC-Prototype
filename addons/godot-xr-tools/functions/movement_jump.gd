@tool
class_name XRToolsMovementJump
extends XRToolsMovementProvider

## XR Tools Movement Provider for Jumping
##
## This script provides jumping mechanics for the player. This script works
## with the [XRToolsPlayerBody] attached to the players [XROrigin3D].
##
## The player enables jumping by attaching an [XRToolsMovementJump] as a
## child of the appropriate [XRController3D], then configuring the jump button
## and jump velocity.

## Movement provider order
@export var order : int = 20

## Button to trigger jump
@export var jump_button_action : String = "trigger_click"

# Node references
@onready var _controller := XRHelpers.get_xr_controller(self)

var jump_count = 0
var _jump_button_down : bool = false  # Track previous button state

# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "XRToolsMovementJump" or super(name)

# Perform jump movement
func physics_movement(_delta: float, player_body: XRToolsPlayerBody, _disabled: bool):
	# Skip if the jump controller isn't active
	if !_controller.get_is_active():
		return
	
	# Detect button down and pressed states
	var jump_button_down := _controller.is_button_pressed(jump_button_action)
	var jump_button_pressed := jump_button_down and !_jump_button_down
	_jump_button_down = jump_button_down
	
	# Request jump only on button press (not hold)
	if jump_button_pressed:
		player_body.request_jump()
		jump_count += 1
		
		if jump_count >= 5:
			GlobalVar.increase_physical()
			jump_count = 0  # Reset count after increasing physical

# This method verifies the movement provider has a valid configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()
	
	# Check the controller node
	if !XRHelpers.get_xr_controller(self):
		warnings.append("This node must be within a branch of an XRController3D node")
	
	# Return warnings
	return warnings
