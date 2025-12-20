class_name FloatingIndicator

extends Node3D

@onready var label_3d := $Label3D
@onready var animation_player := $AnimationPlayer

func setup(text: String, color: Color = Color.SEA_GREEN):
	label_3d.text = text
	label_3d.modulate = color
	
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_3d.no_depth_test = true

	label_3d.outline_size = 4
	label_3d.outline_modulate = Color.BLACK
	
	animation_player.play("float_up")
	
	scale = Vector3(0.3, 0.3, 0.3)
	
	label_3d.pixel_size = 0.002
	label_3d.font_size = 96


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var xr_camera = get_viewport().get_camera_3d()
	if xr_camera:
		look_at(xr_camera.global_position, Vector3.UP)


func _on_animation_finished(anim_name: String):
	queue_free()
