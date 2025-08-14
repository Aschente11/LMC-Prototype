extends Node3D
@export var wave_amplitude: float = 0.4  # How high the wave goes
@export var wave_speed: float = 2.0      # Speed of the wave animation
@export var wave_frequency: float = 1.1  # How many waves across the text (lower = longer waves)
@export var character_spacing: float = 0.15  # Space between characters
@export var possible_texts: Array[String] = [
	"tralalerotralalatralalerolala",
	"tengenengenengeneng", 
	"I was a girl in a village doing alright~"
]
var character_meshes: Array[MeshInstance3D] = []
var base_positions: Array[Vector3] = []
var time_passed: float = 0.0
var is_text_active: bool = false  # Track if text should be animated

# Reference to your material and font (you'll need to set these)
@export var text_material: StandardMaterial3D
@export var text_font: FontFile

func _ready():
	# Set up the material and font if not already set
	if not text_material:
		text_material = StandardMaterial3D.new()
		text_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		text_material.albedo_color = Color(1, 0.55, 0, 1)
		text_material.emission_enabled = true
		text_material.emission = Color(0.21, 0, 0, 1)
	
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
		create_wavy_text()
	else:
		# Hide text when stimulation is not 2
		visible = false
		is_text_active = false
		clear_text()

func clear_text():
	# Clear existing characters
	for mesh in character_meshes:
		if is_instance_valid(mesh):
			mesh.queue_free()
	character_meshes.clear()
	base_positions.clear()

func create_wavy_text():
	# Clear existing characters first
	clear_text()
	
	# Pick random text
	if possible_texts.size() > 0:
		var chosen_text = possible_texts.pick_random()
		
		# Create individual mesh instances for each character
		var x_offset = 0.0
		for i in range(chosen_text.length()):
			var char = chosen_text[i]
			
			# Skip spaces by just adding to offset
			if char == " ":
				x_offset += character_spacing
				continue
			
			# Create TextMesh for this character
			var char_mesh = TextMesh.new()
			char_mesh.material = text_material
			char_mesh.text = char
			char_mesh.font = text_font
			char_mesh.font_size = 28
			
			# Create MeshInstance3D for this character
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = char_mesh
			add_child(mesh_instance)
			
			# Set position
			var base_pos = Vector3(x_offset, 0, 0)
			mesh_instance.position = base_pos
			
			# Store references
			character_meshes.append(mesh_instance)
			base_positions.append(base_pos)
			
			# Get actual character width for better spacing
			if text_font:
				var char_size = text_font.get_char_size(char.unicode_at(0), 28)
				x_offset += char_size.x * 0.01 + character_spacing  # Scale down the font size units
			else:
				x_offset += character_spacing

func _process(delta):
	# Only animate if text is active and visible
	if not is_text_active or not visible:
		return
		
	time_passed += delta
	
	# Apply wave effect to each character
	for i in range(character_meshes.size()):
		if character_meshes[i] and is_instance_valid(character_meshes[i]) and base_positions.size() > i:
			# Calculate wave based on character position in the text (creates the wave shape)
			var wave_offset = sin((base_positions[i].x * wave_frequency) + (time_passed * wave_speed)) * wave_amplitude
			character_meshes[i].position = base_positions[i] + Vector3(0, wave_offset, 0)

# Optional: Function to change text dynamically
func set_wavy_text(new_text: String):
	# Add the new text to possible texts and recreate
	possible_texts = [new_text]  # Or append if you want to keep others
	if is_text_active:  # Only create if currently active
		create_wavy_text()

# Optional: Function to randomize text again
func randomize_text():
	if is_text_active:  # Only create if currently active
		create_wavy_text()
