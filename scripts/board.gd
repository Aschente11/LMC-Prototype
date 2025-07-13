extends Node3D

@onready var text: MeshInstance3D = $text
@export var full_text: String = "Things to do today:\n  1. cook bfast\n  2. draw a house\n  3. clean my shi\n 4. sleep early"
@export var wipes_per_letter: int = 3  # Number of wipes needed to reveal one letter

var current_text: String = ""
var letter_index: int = 0
var is_initialized: bool = false
var wipe_count: int = 0

func _ready():
	text.visible = false
	if text.mesh is TextMesh:
		text.mesh.text = ""

func _on_ois_wipe_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	text.visible = true
	
	# Only initialize once, don't reset if already started
	if not is_initialized:
		letter_index = 0
		current_text = ""
		wipe_count = 0
		is_initialized = true
	
	_check_reveal_letter()

func _check_reveal_letter():
	wipe_count += 1
	if wipe_count >= wipes_per_letter:
		_reveal_next_letter()
		wipe_count = 0  # Reset counter after revealing letter

func _reveal_next_letter():
	if letter_index < full_text.length():
		current_text += full_text[letter_index]
		text.mesh.text = current_text
		letter_index += 1

func _on_ois_wipe_receiver_action_in_progress(requirement: Variant, total_progress: Variant) -> void:
	_check_reveal_letter()

func _on_ois_wipe_receiver_action_completed(requirement: Variant, total_progress: Variant) -> void:
	# Optional: reveal final letter when completed
	pass
