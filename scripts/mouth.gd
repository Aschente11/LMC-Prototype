extends Area3D

@onready var eating_sfx: AudioStreamPlayer3D = $"Eating sfx"
@onready var check_timer: Timer = Timer.new()
@onready var haptic_timer: Timer = Timer.new()  # New timer for haptic feedback
@onready var particles: GPUParticles3D = GPUParticles3D.new()
@onready var right_hand = $"../../XRController3DRight"
@onready var left_hand = $"../../XRController3DLeft"

var eating_distance: float = 0.25
var eaten_foods: Array = []
var eating_foods: Dictionary = {}  # {food: eating_time}
var eating_duration: float = 5
var haptic_interval: float = 0.1  # How often to trigger haptic feedback (in seconds)

func _ready() -> void:
	add_child(check_timer)
	check_timer.wait_time = 0.1
	check_timer.timeout.connect(_check_for_food)
	check_timer.start()
	
	# Setup haptic timer
	add_child(haptic_timer)
	haptic_timer.wait_time = haptic_interval
	haptic_timer.timeout.connect(_trigger_continuous_haptics)
	haptic_timer.one_shot = false  # Make it repeat
	
	# Setup particles
	add_child(particles)
	setup_particles()

func setup_particles():
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, -1, 0)
	material.initial_velocity_min = 0.5
	material.initial_velocity_max = 1.5
	material.gravity = Vector3(0, -3, 0)
	material.scale_min = 0.05
	material.scale_max = 0.15
	material.color = Color(0.8, 0.6, 0.3)
	
	particles.process_material = material
	particles.amount = 30
	particles.lifetime = 1.0
	particles.emitting = false

func _physics_process(delta):
	update_eating_foods(delta)

func _check_for_food():
	var food_items = get_tree().get_nodes_in_group("food")
	
	for food in food_items:
		if food in eaten_foods:
			continue
			
		var distance = global_position.distance_to(food.global_position)
		
		if distance <= eating_distance:
			if not food in eating_foods:
				start_eating(food)
		else:
			if food in eating_foods:
				stop_eating(food)

func start_eating(food: Node):
	eating_foods[food] = 0.0
	if not eating_sfx.playing: 
		eating_sfx.play()
	particles.global_position = food.global_position
	particles.emitting = true
	
	# Start continuous haptic feedback
	if not haptic_timer.is_stopped():
		haptic_timer.stop()
	haptic_timer.start()
	
func stop_eating(food: Node):
	eating_foods.erase(food)
	food.scale = Vector3.ONE
	particles.emitting = false
	if eating_foods.is_empty():
		eating_sfx.stop()
		# Stop haptic feedback when no longer eating
		haptic_timer.stop()

func update_eating_foods(delta):
	for food in eating_foods.keys():
		eating_foods[food] += delta
		var progress = eating_foods[food] / eating_duration
		
		# Scale down food
		food.scale = Vector3.ONE * (1.0 - progress)
		
		# Update particle position
		particles.global_position = food.global_position
		
		# Finish eating
		if progress >= 1.0:
			finish_eating(food)

func finish_eating(food: Node):
	eating_foods.erase(food)
	eaten_foods.append(food)
	particles.emitting = false
	food.queue_free()
	if eating_foods.is_empty():
		eating_sfx.stop()
		# Stop haptic feedback when finished eating
		haptic_timer.stop()

# New function that gets called repeatedly while eating
func _trigger_continuous_haptics():
	if not eating_foods.is_empty():
		trigger_haptic_feedback()

func trigger_haptic_feedback(duration: float = 0.1, frequency: float = 0.3, amplitude: float = 0.4) -> void:
	right_hand.trigger_haptic_pulse("haptic", frequency, amplitude, duration, 0.0)
	left_hand.trigger_haptic_pulse("haptic", frequency, amplitude, duration, 0.0)
