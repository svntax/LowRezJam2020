extends Node2D

signal exit_touched()

func _on_PlayerDetect_body_entered(body):
	if body.is_in_group("Players"):
		get_tree().get_root().get_node("Gameplay").exit_reached()
