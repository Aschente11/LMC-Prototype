extends Event

@onready var next_scene = preload("res://scenes/main.tscn").instantiate()
@onready var anim_player: AnimationPlayer = $"../AnimationPlayer"

func _on_qte_success() -> void:
	anim_player.play("Blinking")
	close_event()

func _on_qte_fail() -> void:
	anim_player.play("Blinking")
	close_event()
	get_tree().change_scene_to_packed(next_scene)
	print("Changed Scene")
