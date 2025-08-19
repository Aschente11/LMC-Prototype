extends Area3D

@onready var eating_sfx: AudioStreamPlayer3D = $"Eating sfx"

signal food_eaten(food)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	food_eaten.connect(_on_food_eaten)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("food"):
		emit_signal("food_eaten", body)

func _on_food_eaten(food: Node) -> void:
	eating_sfx.play()
	food.queue_free()
