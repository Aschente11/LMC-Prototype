extends Node3D

@onready var painting = $ArtSupplyPropSet/Canvas/painting
@onready var painting_sfx = $painting_sfx
@export var opacity_per_wipe: float = 0.05 
var painting_material: StandardMaterial3D
var is_initialized := false
var current_opacity := 0.0
var has_completed := false  # Track if we've already triggered the completion

func _ready() -> void:
	painting.visible = false

func _on_ois_wipe_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if not is_initialized:
		_initialize_painting()
	_handle_wipe_input()

func _initialize_painting():
	is_initialized = true
	painting.visible = true
	
	# Get the material directly
	painting_material = painting.get_active_material(0)
	
	# Ensure transparency is enabled
	if painting_material:
		painting_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Start fully transparent (ffffff00)
	current_opacity = 0.0
	set_painting_opacity(current_opacity)

func _handle_wipe_input():
	if current_opacity < 1.0:
		_increase_opacity()
	painting_sfx.play()

func _increase_opacity():
	current_opacity += opacity_per_wipe
	current_opacity = clamp(current_opacity, 0.0, 1.0)
	set_painting_opacity(current_opacity)
	
	# Check if we just reached full opacity
	if current_opacity >= 1.0 and not has_completed:
		_on_painting_fully_revealed()

func set_painting_opacity(opacity: float) -> void:
	if painting_material:
		# ffffff00 to ffffffff
		painting_material.albedo_color = Color(1.0, 1.0, 1.0, opacity)

func _on_painting_fully_revealed():
	has_completed = true
	GlobalVar.decrease_physical()
	GlobalVar.increase_emotional()

func _on_ois_wipe_receiver_action_in_progress(requirement: Variant, total_progress: Variant) -> void:
	_handle_wipe_input()

func _on_ois_wipe_receiver_action_completed(requirement: Variant, total_progress: Variant) -> void:
	# Ensure fully visible when completed
	current_opacity = 1.0
	set_painting_opacity(1.0)
	
	# Trigger completion if not already done
	if not has_completed:
		_on_painting_fully_revealed()
