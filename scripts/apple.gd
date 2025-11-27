extends XRToolsPickable
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sound_effect: AudioStreamPlayer3D = $sfx
@onready var apple_slice1 = $RightQuarter_Apple
@onready var apple_slice2 = $RightQuarter_Apple2
@onready var apple_slice3 = $LeftQuarter_Apple
@onready var apple_slice4 = $LeftQuarter_Apple2
@onready var make_bfast_sfx = $make_bfast
var is_cut = 0

func _ready() -> void:
	add_to_group("food")
	apple_slice1.add_to_group("food")
	apple_slice2.add_to_group("food")
	apple_slice3.add_to_group("food")
	apple_slice4.add_to_group("food")
	
	visible = true

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if is_cut == 0:
		sound_effect.play()
		await get_tree().create_timer(1.0).timeout
		anim_player.play("quarter_apple_slice")
		is_cut += 1
		
		GlobalVar.decrease_physical()
