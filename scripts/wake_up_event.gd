extends Event

@onready var anim_player: AnimationPlayer = $"../AnimationPlayer"

func _on_qte_success() -> void:
	anim_player.play("Blinking")
	close_event()

func _on_qte_fail() -> void:
	#$QTE.start_qte()
	anim_player.play("Blinking")
	close_event()
