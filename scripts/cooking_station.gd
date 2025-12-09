extends Node3D

@onready var fire1 = $Fire1
@onready var fire2 = $Fire2
@onready var fire3 = $Fire3
@onready var fire4 = $Fire4
@onready var stove_sfx = $stove
@onready var water_sink = $water

@onready var plate1 = $plate
@onready var plate2 = $plate2
@onready var plate3 = $plate3

@onready var water_area = $water/Area3D

@onready var dirt1 = $plate/MeshInstance3D
@onready var dirt2 = $plate2/MeshInstance3D
@onready var dirt3 = $plate3/MeshInstance3D


var stove1_is_open = false
var stove2_is_open = false
var stove3_is_open = false
var stove4_is_open = false
var sink_is_open = false

# Track total dirt meshes and cleaned count
var total_dirt_count = 0
var cleaned_dirt_count = 0

func _ready() -> void:
	fire1.visible = false
	fire2.visible = false
	fire3.visible = false
	fire4.visible = false
	water_sink.visible = false
	
	dirt1.add_to_group("dirt")
	dirt2.add_to_group("dirt")
	dirt3.add_to_group("dirt")
	# Count all dirt meshes and setup collision detection
	setup_plates()

func setup_plates() -> void:
	var plates = [plate1, plate2, plate3]

	for plate in plates:
		for child in plate.get_children():
			if child.is_in_group("dirt"):   # <-- FIX HERE
				total_dirt_count += 1

				var area = Area3D.new()
				child.add_child(area)

				var collision_shape = CollisionShape3D.new()
				var sphere_shape = SphereShape3D.new()
				sphere_shape.radius = 0.02
				collision_shape.shape = sphere_shape
				area.add_child(collision_shape)

				area.collision_layer = 0
				area.collision_mask = 1

				area.area_entered.connect(_on_dirt_touched_water.bind(child))

func _on_dirt_touched_water(area: Area3D, dirt_mesh: MeshInstance3D) -> void:
	if area == water_area and sink_is_open:
		dirt_mesh.queue_free()
		cleaned_dirt_count += 1
		
		# Check if all dirt is cleaned
		if cleaned_dirt_count >= total_dirt_count:
			print("All plates cleaned!")
			GlobalVar.decrease_emotional()
			GlobalVar.decrease_physical()

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if stove2_is_open:
		fire2.visible = false
		stove2_is_open = false
	else:
		stove_sfx.play()
		fire2.visible = true
		stove2_is_open = true

func _on_ois_strike_receiver_1_action_started(requirement: Variant, total_progress: Variant) -> void:
	if stove1_is_open:
		fire1.visible = false
		stove1_is_open = false
	else:
		stove_sfx.play()
		fire1.visible = true
		stove1_is_open = true
		
func _on_ois_strike_receiver_2_action_started(requirement: Variant, total_progress: Variant) -> void:
	if stove3_is_open:
		fire3.visible = false
		stove3_is_open = false
	else:
		stove_sfx.play()
		fire3.visible = true
		stove3_is_open = true
		
func _on_ois_strike_receiver_3_action_started(requirement: Variant, total_progress: Variant) -> void:
	if stove4_is_open:
		fire4.visible = false
		stove4_is_open = false
	else:
		stove_sfx.play()
		fire4.visible = true
		stove4_is_open = true

func _on_ois_strike_receiver_5_action_started(requirement: Variant, total_progress: Variant) -> void:
	if sink_is_open:
		water_sink.visible = false
		sink_is_open = false
	else:
		water_sink.visible = true
		sink_is_open = true
