extends Event
@onready var make_bfast_sfx: AudioStreamPlayer = $"../make_bfast"

func _ready() -> void:
	GlobalVar.eating_milestone.connect(_on_eating_milestone)
	
func _on_event_started() -> void:
	#var make_bfast_text = get_tree().get_first_node_in_group("make_bfast_text")
	#make_bfast_text.visible = true
	make_bfast_sfx.play()
	 
func _on_eating_milestone(milestone: int):
	#var make_bfast_text = get_tree().get_first_node_in_group("make_bfast_text")
	#make_bfast_text.visible = false
	close_event()

	
