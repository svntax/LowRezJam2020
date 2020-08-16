extends Area2D

func _on_HeartPickup_body_entered(body):
	if body.is_in_group("Players"):
		body.heal(1)
		queue_free()
