extends XRToolsPickable

@onready var anim_player = $AnimationPlayer

var cap_is_on = 1

func _ready():
	add_to_group("tool")
	action_pressed.connect(_on_action_pressed)

func _on_action_pressed(pickable_object):
	if cap_is_on == 1:
		anim_player.play("cap_off")
		cap_is_on -= 1
	
	elif cap_is_on == 0:
		anim_player.play("cap_on")
		cap_is_on += 1
