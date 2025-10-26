extends XRToolsPickable

@onready var anim_player = $AnimationPlayer
@onready var raycast = $RayCast3D
@onready var inventory_slot = $InventorySlot
@onready var frying_sfx = $Frying

var has_flipped = false
var pour_time = 0.0
var pour_threshold = 3.0  # 3 seconds of pouring
var is_being_poured_on = false
var slot_revealed = false

func _ready():
	super._ready() 
	
	# Hide inventory slot at start
	if inventory_slot:
		inventory_slot.visible = false
		inventory_slot.scale = Vector3.ZERO
	
	if raycast:
		raycast.enabled = true
		raycast.collide_with_areas = true
		raycast.collide_with_bodies = true

func _physics_process(delta: float) -> void:
	if not raycast:
		return
	
	# Check for cupboard collision (flip)
	if raycast.is_colliding():
		var hit_object = raycast.get_collider()
		
		if hit_object and hit_object is StaticBody3D:
			if not has_flipped:
				anim_player.play("pancake_flip")
				#ADD 0.6 SEC DELAY HERE TO MAKE IT REALISTIC
				#frying_sfx.play()
				has_flipped = true
				
				await get_tree().create_timer(2.0).timeout
				has_flipped = false

# Called by carton when it starts/stops pouring on this pan
func _on_pouring_started():
	is_being_poured_on = true

func _on_pouring_stopped():
	is_being_poured_on = false
	pour_time = 0.0

func _process(delta: float) -> void:
	# Track pouring time
	if is_being_poured_on and not slot_revealed:
		pour_time += delta
		
		# Check if threshold reached
		if pour_time >= pour_threshold:
			reveal_inventory_slot()

func reveal_inventory_slot():
	if slot_revealed or not inventory_slot:
		return
	
	slot_revealed = true
	inventory_slot.visible = true
	frying_sfx.play()
	
	# Smooth scale animation
	var tween = create_tween()
	tween.tween_property(inventory_slot, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
