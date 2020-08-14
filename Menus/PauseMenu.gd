extends Control

func _on_Resume_pressed():
	get_tree().paused = false
	hide()

func _on_Exit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Main.tscn")
