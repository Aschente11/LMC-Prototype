extends Node3D

var notes_complete = 0

func _on_inventory_slot_1_current_object_in_slot(object: Variant, row: Variant, col: Variant) -> void:
	notes_complete += 1
	check_all_slots_filled()

func _on_inventory_slot_2_current_object_in_slot(object: Variant, row: Variant, col: Variant) -> void:
	notes_complete += 1
	check_all_slots_filled()

func _on_inventory_slot_3_current_object_in_slot(object: Variant, row: Variant, col: Variant) -> void:
	notes_complete += 1
	check_all_slots_filled()

func check_all_slots_filled() -> void:
	if notes_complete == 5:
		GlobalVar.decrease_emotional()
