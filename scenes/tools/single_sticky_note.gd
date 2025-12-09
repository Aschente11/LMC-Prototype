extends XRToolsPickable

@onready var text: MeshInstance3D = $text
@onready var writing_sfx: AudioStreamPlayer3D = $writing
@export var wipes_per_letter: int = 7

var full_text: String = ""
var current_text: String = ""
var letter_index := 0
var wipe_count := 0
var is_actively_wiping := false
var is_initialized := false
var wipe_timer: Timer
var unique_text_mesh: TextMesh  # Each note gets its own mesh
var task_index: int

func _ready():
	add_to_group("notes")
	text.visible = false
	
	# CRITICAL FIX: Create a unique TextMesh for this note
	if text.mesh is TextMesh:
		unique_text_mesh = text.mesh.duplicate()
		text.mesh = unique_text_mesh
		unique_text_mesh.text = ""
	
	wipe_timer = Timer.new()
	wipe_timer.wait_time = 0.05
	wipe_timer.one_shot = true
	wipe_timer.timeout.connect(_on_wipe_timeout)
	add_child(wipe_timer)
	
func _process(delta):
	if task_index < TaskManager.active_tasks.size():
		if TaskManager.active_tasks[task_index].done:
			if unique_text_mesh:
				unique_text_mesh.text = "Done"

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
	if unique_text_mesh:
		unique_text_mesh.text = ""
	
	# Ask TaskManager for text
	full_text = TaskManager.request_task()
	task_index = TaskManager.current_task_index
	if full_text == "":
		full_text = "(nothing \n to write \n yet)"

func _handle_wipe_input():
	if letter_index < full_text.length():
		if not is_actively_wiping:
			_start_sound()
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
		if unique_text_mesh:
			unique_text_mesh.text = current_text
		letter_index += 1
		if letter_index >= full_text.length():
			_stop_sound()
			_notify_task_complete()

func _on_ois_wipe_receiver_action_in_progress(requirement, total_progress):
	_handle_wipe_input()

func _on_ois_wipe_receiver_action_completed(requirement, total_progress):
	is_actively_wiping = false
	_stop_sound()

func _on_wipe_timeout():
	is_actively_wiping = false
	_stop_sound()

func _start_sound():
	if writing_sfx.stream and not writing_sfx.playing:
		writing_sfx.play()

func _stop_sound():
	if writing_sfx.playing:
		writing_sfx.stop()

func _notify_task_complete():
	TaskManager.mark_current_done()
