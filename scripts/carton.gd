extends XRToolsPickable

@onready var raycast = $RayCast3D
@onready var liquid_particles = $PancakeLiquid

var current_pan = null  # Track which pan we're pouring on

func _ready():
	super._ready()
	
	if liquid_particles:
		liquid_particles.visible = false
	
	if raycast:
		raycast.enabled = true
		raycast.collide_with_areas = true
		raycast.collide_with_bodies = true

func _physics_process(delta: float) -> void:
	if not raycast or not liquid_particles:
		return
	
	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		
		# Check if hitting SnapZone (pan area)
		if hit_object and hit_object.name == "SnapZone":
			liquid_particles.visible = true
			
			# Find the pan (should be parent or nearby)
			var pan = find_pan_from_snapzone(hit_object)
			if pan and pan != current_pan:
				# Started pouring on new pan
				if current_pan:
					current_pan._on_pouring_stopped()
				current_pan = pan
				current_pan._on_pouring_started()
			elif not pan and current_pan:
				# Lost the pan reference
				current_pan._on_pouring_stopped()
				current_pan = null
		else:
			# Not hitting snap zone anymore
			liquid_particles.visible = false
			if current_pan:
				current_pan._on_pouring_stopped()
				current_pan = null
	else:
		# Not hitting anything
		liquid_particles.visible = false
		if current_pan:
			current_pan._on_pouring_stopped()
			current_pan = null

func find_pan_from_snapzone(snapzone: Node) -> Node:
	# Try to find pan - could be parent, grandparent, or sibling
	var parent = snapzone.get_parent()
	
	# Check if parent is the pan
	if parent and parent.has_method("_on_pouring_started"):
		return parent
	
	# Check grandparent
	if parent:
		var grandparent = parent.get_parent()
		if grandparent and grandparent.has_method("_on_pouring_started"):
			return grandparent
	
	# Search in scene tree for pan node (make sure pan is in "pan" group)
	var pan = get_tree().get_first_node_in_group("pan")
	return pan
