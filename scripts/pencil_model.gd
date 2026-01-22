extends XRToolsPickable

@onready var anim_player = $AnimationPlayer
@onready var cap_open = $cap_open
@onready var cap_close = $cap_close
@onready var marker_mesh = $"marker base2"

var cap_is_on = 1

func _ready():
	add_to_group("tool")
	action_pressed.connect(_on_action_pressed)

func _on_action_pressed(pickable_object):
	if cap_is_on == 1:
		anim_player.play("cap_off")
		cap_open.play()
		cap_is_on -= 1
	
	elif cap_is_on == 0:
		anim_player.play("cap_on")
		cap_close.play()
		cap_is_on += 1

func _on_write_tasks_event_ended() -> void:
	marker_mesh.get_active_material(0)
	marker_mesh.set_surface_override_material(0, marker_mesh)
	marker_mesh.next_pass = null
