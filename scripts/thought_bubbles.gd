extends MeshInstance3D

@export var pulse_size: float = 0.05  # ±5% size change
@export var pulse_speed: float = 5.0  # Speed of the pulsing
@export var possible_texts: Array[String] = [
	"Was that event today",
	"Omg i havent done my dailies",
	"Why did I do that ughhhh",
	"What is life even about",
]

var base_scale: Vector3
var time_passed: float = 0.0

func _ready():
	base_scale = scale
	
	# Pick a random text from the array
	if possible_texts.size() > 0:
		var chosen_text = possible_texts.pick_random()
		
		# Assuming your MeshInstance3D uses a TextMesh
		var text_mesh := mesh
		if text_mesh is TextMesh:
			text_mesh.text = chosen_text

func _process(delta):
	time_passed += delta
	var pulse_factor = sin(time_passed * pulse_speed) * pulse_size
	scale = base_scale * (1.0 + pulse_factor)
