extends Node3D
@onready var audio = $"../AudioStreamPlayer3D"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_plushie_picked_up(pickable: Variant) -> void:
	if not audio.playing:
		audio.play()
	await get_tree().create_timer(5.0).timeout
	GlobalVar.increase_emotional()


func _on_plushie_released(pickable: Variant, by: Variant) -> void:
	audio.stop()
	
