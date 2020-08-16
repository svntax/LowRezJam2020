extends Area2D

func _ready():
	collision_mask = 0
	$Timer.start()

func _on_HeartPickup_body_entered(body):
	if body.is_in_group("Players"):
		body.heal(1)
		queue_free()

func _on_Timer_timeout():
	collision_mask = 2 # PLAYER layer
