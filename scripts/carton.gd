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
		
		# Find the actual pan node from whatever we hit
		var pan = find_pan_from_node(hit_object)
		
		if pan:
			# We're hitting a pan or its collision area
			liquid_particles.visible = true
			
			# Check if we switched pans or just started
			if pan != current_pan:
				# Stop pouring on old pan
				if current_pan:
					current_pan._on_pouring_stopped()
				
				# Start pouring on new pan
				current_pan = pan
				current_pan._on_pouring_started()
		else:
			# Not hitting a pan anymore
			_stop_pouring()
	else:
		# Not hitting anything
		_stop_pouring()

func _stop_pouring():
	liquid_particles.visible = false
	if current_pan:
		current_pan._on_pouring_stopped()
		current_pan = null

func find_pan_from_node(node: Node) -> Node:
	# Check if the node itself is in the "pan" group and has the method
	if node.is_in_group("pan") and node.has_method("_on_pouring_started"):
		return node
	
	# Check parent
	var parent = node.get_parent()
	if parent and parent.is_in_group("pan") and parent.has_method("_on_pouring_started"):
		return parent
	
	# Check grandparent
	if parent:
		var grandparent = parent.get_parent()
		if grandparent and grandparent.is_in_group("pan") and grandparent.has_method("_on_pouring_started"):
			return grandparent
	
	return null
