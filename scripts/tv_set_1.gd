extends Area3D

signal is_sitting(marker)

func _on_body_entered(body):
	is_sitting.emit(self.name)
