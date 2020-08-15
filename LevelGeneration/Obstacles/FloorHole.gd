extends Area2D

func _on_FloorHole_body_entered(body):
	if body.has_method("fall_in_hole"):
		body.fall_in_hole()
