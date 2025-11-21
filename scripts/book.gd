extends Node

@onready var journal_cover := $"../quest_log2 (added shapekeys)/Book cover"
@onready var journal_pages := $"../quest_log2 (added shapekeys)/Pages"
@onready var journal_hitbox := $"../CollisionShape3D"
@onready var light := $"../OmniLight3D"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var handle_left := $"../PageTurnerLeft/InteractableHandle"
@onready var handle_right := $"../PageTurnerRight/InteractableHandle"
@onready var inventory_item := $"../InventoryItem"
@onready var page1 = $"../quest_log2 (added shapekeys)/MeshInstance3D/page 1"
@onready var page2 = $"../quest_log2 (added shapekeys)/MeshInstance3D/page 2"
@onready var page3 = $"../quest_log2 (added shapekeys)/MeshInstance3D/page 3"

# Track current page
var current_page: int = 1
var total_pages: int = 3

func _ready() -> void:
	close_journal()
	handle_left.enabled = false
	handle_right.enabled = false
	
	# Start on page 1
	current_page = 1
	update_page_visibility()

func _process(delta: float) -> void:
	if not handle_left.is_picked_up():
		handle_left.global_transform = handle_left.handle_origin.global_transform
	
	if not handle_right.is_picked_up():
		handle_right.global_transform = handle_right.handle_origin.global_transform
	
	# Update handle states based on current page
	if inventory_item.is_grabbed:
		handle_left.enabled = current_page < total_pages  # Left goes forward
		handle_right.enabled = current_page > 1  # Right goes back

func update_page_visibility() -> void:
	# Hide all pages first
	page1.visible = false
	page2.visible = false
	page3.visible = false
	
	# Show only the current page
	match current_page:
		1:
			page1.visible = true
		2:
			page2.visible = true
		3:
			page3.visible = true
			GlobalVar.decrease_emotional()
	
	print("Showing page: ", current_page)

func open_journal() -> void:
	animation_player.play("book_opening")
	await animation_player.animation_finished
	light.light_energy = 0.1
	
	# Reset to page 1 when opening
	current_page = 1
	update_page_visibility()

func close_journal() -> void:
	light.light_energy = 0
	animation_player.play("book_closing")
	await animation_player.animation_finished

func _on_ois_journal_grabbed(pickable: Variant, by: Variant) -> void:
	if by is XRToolsFunctionPickup:
		open_journal()
		inventory_item.call_deferred("_force_enlarge_item")
		inventory_item.is_grabbed = true
		
		handle_left.enabled = true
		handle_right.enabled = true

func _on_ois_journal_released(pickable: Variant, by: Variant) -> void:
	if by is XRToolsFunctionPickup:
		close_journal()
		inventory_item.is_grabbed = false
		inventory_item.call_deferred("_force_shrink_item")
		
		handle_left.enabled = false
		handle_right.enabled = false

func _on_page_turn_left_action_completed(requirement: Variant, total_progress: Variant) -> void:
	if animation_player.is_playing():
		return
	
	# Check if it's actually the left handle that was grabbed
	if not handle_left.is_picked_up():
		return
	
	# Can't go forward if on last page
	if current_page >= total_pages:
		return
	
	animation_player.play("flip_page_left")
	await animation_player.animation_finished
	
	# Go to next page
	current_page += 1
	update_page_visibility()
	
	animation_player.play("RESET")

func _on_page_turn_right_action_completed(requirement: Variant, total_progress: Variant) -> void:
	if animation_player.is_playing():
		return
	
	# Check if it's actually the right handle that was grabbed
	if not handle_right.is_picked_up():
		return
	
	# Can't go back if on first page
	if current_page <= 1:
		return
	
	animation_player.play("flip_page_right")
	await animation_player.animation_finished
	
	# Go to previous page
	current_page -= 1
	update_page_visibility()
	
	animation_player.play("RESET")
