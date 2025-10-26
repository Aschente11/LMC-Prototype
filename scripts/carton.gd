extends XRToolsPickable

@onready var raycast = $RayCast3D
@onready var liquid_particles = $PancakeLiquid

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
		
		# Check if hitting SnapZone
		if hit_object and hit_object.name == "SnapZone":
			liquid_particles.visible = true
		else:
			liquid_particles.visible = false
	else:
		liquid_particles.visible = false
