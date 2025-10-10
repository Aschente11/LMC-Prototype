extends XRToolsPickable

@onready var text: MeshInstance3D = $text
#@onready var writing_sfx: AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var wipes_per_letter: int = 1
var full_text: String = ""   # Filled when the player starts writing
var current_text: String = ""
var letter_index := 0
var wipe_count := 0
var is_actively_wiping := false
var is_initialized := false
var wipe_timer: Timer

func _ready():
	add_to_group("notes")
	text.visible = false
	if text.mesh is TextMesh:
		text.mesh.text = ""

	wipe_timer = Timer.new()
	wipe_timer.wait_time = 0.2
	wipe_timer.one_shot = true
	wipe_timer.timeout.connect(_on_wipe_timeout)
	add_child(wipe_timer)

# When wiping starts
func _on_ois_wipe_receiver_action_started(requirement, total_progress):
	if not is_initialized:
		_initialize_text()
	_handle_wipe_input()

func _initialize_text():
	is_initialized = true
	text.visible = true
	letter_index = 0
	current_text = ""
	wipe_count = 0
	if text.mesh is TextMesh:
		text.mesh.text = ""

	# Ask TaskManager for text
	full_text = GlobalVar.request_task()
	if full_text == "":
		full_text = "(nothing to write yet)"

func _handle_wipe_input():
	if letter_index < full_text.length():
		#if not is_actively_wiping:
			#_start_sound()
		is_actively_wiping = true
		wipe_timer.start()
	_check_reveal_letter()

func _check_reveal_letter():
	wipe_count += 1
	if wipe_count >= wipes_per_letter:
		_reveal_next_letter()
		wipe_count = 0

func _reveal_next_letter():
	if letter_index < full_text.length():
		current_text += full_text[letter_index]
		text.mesh.text = current_text
		letter_index += 1

		if letter_index >= full_text.length():
			#_stop_sound()
			_notify_task_complete()

func _on_wipe_timeout():
	is_actively_wiping = false
	#_stop_sound()

#func _start_sound():
	#if writing_sfx.stream and not writing_sfx.playing:
		#writing_sfx.play()
#
#func _stop_sound():
	#if writing_sfx.playing:
		#writing_sfx.stop()

func _notify_task_complete():
	# Tell TaskManager this note finished
	GlobalVar.mark_current_done()
