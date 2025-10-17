extends Area3D

@onready var audio_player = $RemoveNoteAudio
#
#@export var post_it_scene: PackedScene
#@export var max_stack_count: int = 50  # Maximum notes in the stack
#@export var spawn_offset: Vector3 = Vector3(0, 0, 0)  # Offset from snap zone
#
#var current_stack_count: int = 50  # Track remaining notes
#var snap_zone: XRToolsSnapZone
#var inventory_slot: Node3D
#
func _ready():
	add_to_group("notes")
	## Get references to the snap zone and inventory slot
	#inventory_slot = $InventorySlot
	#snap_zone = $InventorySlot/SnapZone
	#
	## Connect to the snap zone's signals
	#if snap_zone:
		#snap_zone.has_picked_up.connect(_on_post_it_picked_up)
	#
	## Initialize stack count
	#current_stack_count = max_stack_count
	#update_stack_visibility()
#
#func _on_post_it_picked_up(pickable: XRToolsPickable):
	## Decrease stack count
	#current_stack_count -= 1
	#
	## Update visual representation
	#update_stack_visibility()
	#
	## Check if we should spawn a new post-it
	#if current_stack_count > 0:
		## Small delay to allow the picked object to clear
		#await get_tree().create_timer(0.1).timeout
		#spawn_new_post_it()
	#else:
		#print("Stack is empty!")
		## Optionally disable the stack or show empty state
#
#func spawn_new_post_it():
	#if not post_it_scene:
		#push_error("No post_it_scene assigned!")
		#return
	#
	## Instance a new post-it
	#var new_post_it = post_it_scene.instantiate()
	#
	## Add it to the scene tree at the root level (not as child of pack)
	#get_tree().root.add_child(new_post_it)
	#
	## Position it at the snap zone with offset
	#new_post_it.global_position = snap_zone.global_position + spawn_offset
	#new_post_it.global_rotation = snap_zone.global_rotation
	#
	## Wait a frame for the node to be fully ready
	#await get_tree().process_frame
	#
	## Set it as the snap zone's picked up object by setting the property
	#snap_zone.picked_up_object = new_post_it
#
#func update_stack_visibility():
	## Update the stack mesh to show fewer notes
	#var stack_mesh = $"Stack mesh"
	#if stack_mesh:
		## Calculate scale based on remaining notes
		#var scale_factor = float(current_stack_count) / float(max_stack_count)
		#scale_factor = max(scale_factor, 0.1)  # Minimum 10% height
		#
		## Only scale the Y axis (height) of the stack
		#var current_scale = stack_mesh.scale
		#stack_mesh.scale.y = current_scale.y * scale_factor
#
#func refill_stack():
	#"""Call this function to refill the stack"""
	#current_stack_count = max_stack_count
	#update_stack_visibility()
	#
	## Spawn a new post-it if the snap zone is empty
	#if snap_zone and not snap_zone.has_picked_up_object():
		#spawn_new_post_it()
#
#func get_remaining_count() -> int:
	#return current_stack_count


func _on_snap_zone_has_picked_up(what: Variant) -> void:
	audio_player.play()
