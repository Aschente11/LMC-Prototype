extends Area3D

func _on_body_entered(body):
	$"../XROrigin3D/XRToolsPlayerBody".player_calibrate_height = false
	$"../XROrigin3D/XRToolsPlayerBody".player_head_height = -0.29
	print("should be seated")

func _on_body_exited(body):
	$"../XROrigin3D/XRToolsPlayerBody".player_calibrate_height = true
	$"../XROrigin3D/XRToolsPlayerBody".player_head_height = 0.1
