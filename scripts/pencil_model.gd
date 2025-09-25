extends XRToolsPickable

@onready var anim_player = $AnimationPlayer
@onready var cap_open = $cap_open
@onready var cap_close = $cap_close

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
