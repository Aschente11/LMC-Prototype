extends XRToolsSceneBase

var has_initialized = false
var target_scene = ["res://scenes/lmc_day_two.tscn", "res://scenes/lmc_day_three.tscn", "res://scenes/lmc_game_end.tscn"]
var was_pressed = false

func _ready() -> void:
	$finished_sfx.play()
	await get_tree().create_timer(2).timeout
	has_initialized = true

func _on_right_hand_button_pressed(button):
	if has_initialized and not was_pressed and button == "ax_button":
		print(button, " has been pressed!")
		was_pressed = true
		_change_scene()
		#get_tree().change_scene_to_file("res://scenes/lmc_day_two.tscn")

func _change_scene() -> void:
	if not target_scene[TaskManager.current_day] or target_scene[TaskManager.current_day] == "":
		return
		
	self.load_scene(target_scene[TaskManager.current_day])
