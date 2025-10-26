extends Node3D
@onready var fire1 = $Fire1
@onready var fire2 = $Fire2
@onready var fire3 = $Fire3
@onready var fire4 = $Fire4
@onready var stove_sfx = $stove

var stove1_is_open = false
var stove2_is_open = false
var stove3_is_open = false
var stove4_is_open = false

func _ready() -> void:
	fire1.visible = false
	fire2.visible = false
	fire3.visible = false
	fire4.visible = false
	

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if stove2_is_open:
		fire2.visible = false
		stove2_is_open = false
	else:
		stove_sfx.play()
		fire2.visible = true
		stove2_is_open = true


func _on_ois_strike_receiver_1_action_started(requirement: Variant, total_progress: Variant) -> void:
	if stove1_is_open:
		fire1.visible = false
		stove1_is_open = false
	else:
		stove_sfx.play()
		fire1.visible = true
		stove1_is_open = true
		
func _on_ois_strike_receiver_2_action_started(requirement: Variant, total_progress: Variant) -> void:
	if stove3_is_open:
		fire3.visible = false
		stove3_is_open = false
	else:
		stove_sfx.play()
		fire3.visible = true
		stove3_is_open = true
		
func _on_ois_strike_receiver_3_action_started(requirement: Variant, total_progress: Variant) -> void:
	if stove4_is_open:
		fire4.visible = false
		stove4_is_open = false
	else:
		stove_sfx.play()
		fire4.visible = true
		stove4_is_open = true
