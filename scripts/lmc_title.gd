extends XRToolsSceneBase

var xr_interface: XRInterface

@export_file("*.tscn") var target_scene: String

@onready var title_text: MeshInstance3D = $TitleText

# Store original position and rotation
var original_position: Vector3
var original_rotation: Vector3
var time_passed: float = 0.0

var has_initialized: bool = false
var was_pressed: bool = false

# Knife animation properties
@export var knife_rotation_speed: Vector3 = Vector3(0, 0, 90)
@export var knife_orbit_center: Vector3 = Vector3(0, 50, 0)
@export var knife_orbit_radius: float = 25.0
@export var knife_orbit_speed: float = 1.0

# Cat animation properties
@export var cat_rotation_speed: Vector3 = Vector3(90, 0, 0)  # Rotate around Y-axis
@export var cat_orbit_center: Vector3 = Vector3(0, 50, 0)    # Center point for cat orbit
@export var cat_orbit_radius: float = 30.0                   # Radius of cat's orbit
@export var cat_orbit_speed: float = 0.8                     # Speed of cat's orbit

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully!")
		
		#Turn-off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		#Change our main viewport output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected.")
		
	# Store the original transform
	original_position = title_text.position
	original_rotation = title_text.rotation_degrees
	
	# Start background sounds
	$BGsounds.play()
	$AnimationPlayer.play("start")
	await get_tree().create_timer(2).timeout
	has_initialized = true

func _process(delta):
	time_passed += delta
	
	# Animate title text
	simple_bounce()
	
	# Animate knife
	animate_knife()
	
	# Animate cat
	animate_cat()

# Knife animation function (unchanged)
func animate_knife():
	# Rotate the knife on its own axis
	$knife.rotation_degrees += knife_rotation_speed * get_process_delta_time()
	
	# Orbit around the specified center point
	var angle = time_passed * knife_orbit_speed
	
	# Calculate orbital position
	$knife.position.x = knife_orbit_center.x + cos(angle) * knife_orbit_radius
	$knife.position.z = knife_orbit_center.z + sin(angle) * knife_orbit_radius
	$knife.position.y = knife_orbit_center.y

# Cat animation function - orbits around Z-axis
func animate_cat():
	# Rotate the cat on its own axis (around Y-axis for a natural spinning motion)
	$cat.rotation_degrees += cat_rotation_speed * get_process_delta_time()
	
	# Orbit around the Z-axis (circular motion in X-Y plane)
	var angle = time_passed * cat_orbit_speed
	
	# Calculate orbital position (orbiting around Z-axis means moving in X-Y plane)
	$cat.position.x = cat_orbit_center.x + cos(angle) * cat_orbit_radius
	$cat.position.y = cat_orbit_center.y + sin(angle) * cat_orbit_radius
	$cat.position.z = cat_orbit_center.z

# Simple vertical bouncing
func simple_bounce():
	var bounce_height = 2.0  # How high to bounce
	var bounce_speed = 2.0   # How fast to bounce
	
	var bounce_offset = sin(time_passed * bounce_speed) * bounce_height
	title_text.position = original_position + Vector3(0, bounce_offset, 0)

# Method for smooth bouncing using Tween (more performance friendly)
func start_tween_bounce():
	var tween = create_tween()
	tween.set_loops()  # Loop forever
	
	# Bounce up
	tween.tween_property(title_text, "position", original_position + Vector3(0, 2.0, 0), 0.8)
	tween.tween_property(title_text, "position", original_position, 0.8)
	
	# You can also chain scale or rotation animations
	tween.parallel().tween_property(title_text, "scale", Vector3(1.1, 1.1, 1.1), 0.8)
	tween.parallel().tween_property(title_text, "scale", Vector3(1.0, 1.0, 1.0), 0.8)
	
func _left_on_button_pressed(button: String) -> void:
	if has_initialized and not was_pressed and (button == "ax_button" or button == "by_button"):
		print(button, " has been pressed!")
		was_pressed = true
		_change_scene()
		#print("Changed Scene")
		#await get_tree().create_timer(1).timeout
		#get_tree().change_scene_to_file("res://scenes/main.tscn")
		
func _right_on_button_pressed(button: String) -> void:
	if has_initialized and not was_pressed and (button == "ax_button" or button == "by_button"):
		print(button, " has been pressed!")
		was_pressed = true
		_change_scene()
		#was_pressed = true
		#print("Changed Scene")
		#await get_tree().create_timer(1).timeout
		#get_tree().change_scene_to_file("res://scenes/main.tscn")
		
func _change_scene() -> void:
	if not target_scene or target_scene == "":
		return
		
	self.load_scene(target_scene, "day_one")
