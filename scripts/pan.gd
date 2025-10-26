extends XRToolsPickable

@onready var anim_player = $AnimationPlayer
@onready var raycast = $RayCast3D

var has_flipped = false  # Prevent multiple flips

func _ready():
	super._ready() 
	
	if raycast:
		raycast.enabled = true
		raycast.collide_with_areas = true
		raycast.collide_with_bodies = true

func _physics_process(delta: float) -> void:
	if not raycast:
		return
	
	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		
		# Check if hitting StaticBody3D
		if hit_object and hit_object is StaticBody3D:
			if not has_flipped:
				anim_player.play("pancake_flip")
				has_flipped = true
				
				# Reset after animation finishes
				await get_tree().create_timer(2.0).timeout
				has_flipped = false
