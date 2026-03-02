extends Node3D

signal is_crying(marker)

@onready var audio = $"../AudioStreamPlayer3D"

func _on_plushie_picked_up(pickable: Variant) -> void:
	if not audio.playing:
		audio.play()
	
	await get_tree().create_timer(3).timeout
	GlobalVar.increase_emotional()
	is_crying.emit("bed")


func _on_plushie_released(pickable: Variant, by: Variant) -> void:
	audio.stop()
	
