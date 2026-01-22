@warning_ignore("missing_tool")
extends Event

var notes_complete = 0

func current_object_in_slot(_object: Variant, _row: Variant, _col: Variant) -> void:
	notes_complete += 1
	check_all_slots_filled()

func check_all_slots_filled() -> void:
	if notes_complete == 2:
		#GlobalVar.regulate_stimulation()
		GlobalVar.increase_physical()
		GlobalVar.increase_physical()
		GlobalVar.increase_emotional()
		GlobalVar.increase_emotional()
		close_event()
