extends MeshInstance3D
@export var pulse_size: float = 0.04  # ±5% size change
@export var pulse_speed: float = 4.0  # Speed of the pulsing
@export var possible_texts: Array[String] = [
	"Was that event today",
	"Omg i havent done my dailies",
	"Why did I do that ughhhh",
	"What is life even about",
]
var base_scale: Vector3
var time_passed: float = 0.0
var is_text_active: bool = false  # Track if text should be animated

func _ready():
	base_scale = scale
	
	# Connect to stimulation signals
	GlobalVar.stimulation_increase.connect(_on_stimulation_increase)
	GlobalVar.stimulation_decrease.connect(_on_stimulation_decrease)
	call_deferred("check_initial_state")
	
	# Hide initially
	visible = false

func check_initial_state() -> void:
	_on_stimulation_changed(GlobalVar.stimulation)

# Connect to the same signals as the smartwatch for consistency
func _on_stimulation_increase(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_decrease(new_value: int) -> void:
	_on_stimulation_changed(new_value)

func _on_stimulation_changed(new_stimulation_value: int) -> void:
	if new_stimulation_value == 2:
		# Show text and start animation when stimulation is 2
		visible = true
		is_text_active = true
		set_random_text()
	else:
		# Hide text when stimulation is not 2
		visible = false
		is_text_active = false

func set_random_text():
	# Pick a random text from the array
	if possible_texts.size() > 0:
		var chosen_text = possible_texts.pick_random()
		
		# Assuming your MeshInstance3D uses a TextMesh
		var text_mesh := mesh
		if text_mesh is TextMesh:
			text_mesh.text = chosen_text

func _process(delta):
	# Only animate if text is active and visible
	if not is_text_active or not visible:
		return
		
	time_passed += delta
	var pulse_factor = sin(time_passed * pulse_speed) * pulse_size
	scale = base_scale * (1.0 + pulse_factor)
