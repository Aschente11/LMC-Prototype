extends Node3D
@onready var marker: Sprite2D = $GalaxyWatch/screen/SubViewport/Control/MarginContainer/Marker
@onready var stimulation_bar: TextureRect = $GalaxyWatch/screen/SubViewport/Control/MarginContainer/StimulatioinBar
@onready var physical_bar: ProgressBar = $"GalaxyWatch/screen/SubViewport/Control/Physical progress"
@onready var emotional_bar: ProgressBar = $"GalaxyWatch/screen/SubViewport/Control/Emotional progress"


# Store original values
var original_bar_scale: Vector2
var original_marker_scale: Vector2
var original_marker_position: Vector2
var original_marker_rotation: float

func _ready() -> void:
	GlobalVar.stimulation_increase.connect(_on_stimulation_increase)
	GlobalVar.stimulation_decrease.connect(_on_stimulation_decrease)
	GlobalVar.physical_increase.connect(_on_physical_increase)
	GlobalVar.physical_decrease.connect(_on_physical_decrease)
	GlobalVar.emotional_increase.connect(_on_emotional_increase)
	GlobalVar.emotional_decrease.connect(_on_emotional_decrease)
	
	# Store original values at startup
	original_bar_scale = stimulation_bar.scale
	original_marker_scale = marker.scale
	original_marker_position = marker.position
	original_marker_rotation = marker.rotation
	
	# Set pivot points to center for proper scaling
	setup_center_pivots()

func setup_center_pivots() -> void:
	# For TextureRect (stimulation_bar)
	stimulation_bar.pivot_offset = stimulation_bar.size / 2
	
	# For Sprite2D (marker), we need to handle it differently
	# Sprite2D uses centered property or we can adjust the position
	if marker.centered == false:
		marker.centered = true

func _on_stimulation_increase(new_value: int) -> void:
	await get_tree().create_timer(4.0).timeout
	
	# Check if stimulation count is 0, return to original form
	if new_value == 0:
		animate_sequence(original_marker_position, original_marker_rotation, Tween.TRANS_SINE)
		return
	
	# Set direct transform values
	var target_position = Vector2(400, 323)  # Set exact coordinates
	var target_rotation = deg_to_rad(-50)     # Set exact rotation angle
	
	animate_sequence(target_position, target_rotation, Tween.TRANS_ELASTIC)

func _on_stimulation_decrease(new_value: int) -> void:
	await get_tree().create_timer(4.0).timeout
	
	# Check if stimulation count is 0, return to original form
	if new_value == 0:
		animate_sequence(original_marker_position, original_marker_rotation, Tween.TRANS_SINE)
		return
	
	# Set direct transform values
	var target_position = Vector2(107, 168)  # Set exact coordinates
	var target_rotation = deg_to_rad(-237)    # Set exact rotation angle
	
	animate_sequence(target_position, target_rotation, Tween.TRANS_SINE)

func animate_sequence(target_position: Vector2, target_rotation: float, move_transition: Tween.TransitionType) -> void:
	var tween = create_tween()
	
	# Step 1: Enlarge both marker and bar simultaneously
	var enlarged_bar_scale = original_bar_scale * 1.2
	var enlarged_marker_scale = original_marker_scale * 1.7
	
	tween.set_parallel(true)
	tween.tween_property(stimulation_bar, "scale", enlarged_bar_scale, 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(marker, "scale", enlarged_marker_scale, 0.3).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(false)
	
	# Add a small delay to ensure enlargement completes
	tween.tween_callback(func(): pass).set_delay(0.05)
	
	# Step 2: Move marker while both are enlarged
	tween.set_parallel(true)
	tween.tween_property(marker, "position", target_position, 0.5).set_trans(move_transition)
	tween.tween_property(marker, "rotation", target_rotation, 0.5).set_trans(move_transition)
	tween.set_parallel(false)
	
	# Add a small delay to ensure movement completes
	tween.tween_callback(func(): pass).set_delay(0.05)
	
	# Step 3: Return both to original size
	tween.set_parallel(true)
	tween.tween_property(stimulation_bar, "scale", original_bar_scale, 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(marker, "scale", original_marker_scale, 0.3).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(false)

func _on_physical_increase(new_value: int) -> void:
	await get_tree().create_timer(4.0).timeout
	physical_bar.value += 1

func _on_physical_decrease(new_value: int) -> void:
	await get_tree().create_timer(4.0).timeout
	physical_bar.value -= 1

func _on_emotional_increase(new_value: int) -> void:
	await get_tree().create_timer(4.0).timeout
	emotional_bar.value += 1

func _on_emotional_decrease(new_value: int) -> void:
	await get_tree().create_timer(4.0).timeout
	emotional_bar.value -= 1
