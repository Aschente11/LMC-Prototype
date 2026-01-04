extends Node3D

@onready var time_screen = $"GalaxyWatch/time screen"
@onready var bar_screen = $GalaxyWatch/MeshInstance3D

@onready var stimulation: CanvasItem = $GalaxyWatch/SubViewport/Control/Stimulation
@onready var physical: CanvasItem = $GalaxyWatch/SubViewport/Control/Physical
@onready var emotional: CanvasItem = $GalaxyWatch/SubViewport/Control/Emotional

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

	
	var tween = get_tree().create_tween()
	tween.tween_property(stimulation.material, "shader_parameter/value", GlobalVar.stimulation/5.0, 1)
	tween.tween_property(physical.material, "shader_parameter/value", GlobalVar.physical/5.0, 1)
	tween.tween_property(emotional.material, "shader_parameter/value", GlobalVar.emotional/5.0, 1)

# Screen switching logic
func toggle_screen() -> void:
	time_screen.visible = !time_screen.visible
	bar_screen.visible = !bar_screen.visible

func _on_stimulation_increase(old_value: int, new_value: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(stimulation.material, "shader_parameter/value", new_value/5.0, 1)

func _on_stimulation_decrease(old_value: int, new_value: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(stimulation.material, "shader_parameter/value", new_value/5.0, 1)

func _on_physical_increase(old_value: int, new_value: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(physical.material, "shader_parameter/value", new_value/5.0, 1)

func _on_physical_decrease(old_value: int, new_value: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(physical.material, "shader_parameter/value", new_value/5.0, 1)

func _on_emotional_increase(old_value: int, new_value: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(emotional.material, "shader_parameter/value", new_value/5.0, 1)

func _on_emotional_decrease(old_value: int, new_value: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(emotional.material, "shader_parameter/value", new_value/5.0, 1)

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	toggle_screen()
