extends XRToolsPickable

@export var snap_require: String = "bread"

func _ready() -> void:
	add_to_group("bread")
	add_to_group("food")
