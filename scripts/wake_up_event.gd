extends Event

signal qte_success


func _on_qte_success() -> void:
	pass

func _on_qte_fail() -> void:
	$"../QTE".start_qte()
