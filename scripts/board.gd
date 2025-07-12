extends Node3D

@onready var text: MeshInstance3D = $text
@export var full_text: String = "Task for today:\n- cook bfast\n- draw a house\n- clean my shit"
@export var letter_delay: float = 0.1

var current_text: String = ""
var letter_index: int = 0
var is_wiping: bool = false
var letter_timer: Timer

func _ready():
	text.visible = false
	if text.mesh is TextMesh:
		text.mesh.text = ""
	
	# Create a timer for letter revealing
	letter_timer = Timer.new()
	letter_timer.wait_time = letter_delay
	letter_timer.timeout.connect(_reveal_next_letter)
	add_child(letter_timer)

func _on_ois_wipe_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	text.visible = true
	# Initialize but don't start animation yet
	letter_index = 0
	current_text = ""
	is_wiping = false

func _reveal_next_letter():
	if is_wiping and letter_index < full_text.length():
		current_text += full_text[letter_index]
		text.mesh.text = current_text
		letter_index += 1
		
		# Continue timer if still wiping and more letters to reveal
		if is_wiping and letter_index < full_text.length():
			letter_timer.start()

func _on_ois_wipe_receiver_action_in_progress(requirement: Variant, total_progress: Variant) -> void:
	# Start/continue revealing letters only when actively wiping
	if not is_wiping:
		is_wiping = true
		if letter_index < full_text.length():
			letter_timer.start()

func _on_ois_wipe_receiver_action_completed(requirement: Variant, total_progress: Variant) -> void:
	is_wiping = false
	letter_timer.stop()

# Add this function to handle when wiping stops (no progress)
func _on_ois_wipe_receiver_action_stopped():
	is_wiping = false
	letter_timer.stop()
