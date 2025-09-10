extends XRToolsPickable
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sound_effect: AudioStreamPlayer3D = $sfx
var is_cut = 0

func _ready() -> void:
	add_to_group("food")
	visible = true

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if is_cut == 0:
		sound_effect.play()
		await get_tree().create_timer(1.0).timeout
		anim_player.play("quarter_apple_slice")
		is_cut += 1
		
		GlobalVar.increase_stimulation()
		GlobalVar.increase_physical()
		GlobalVar.increase_physical()
		GlobalVar.increase_emotional()
		GlobalVar.increase_emotional()
