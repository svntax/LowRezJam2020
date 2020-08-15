extends Control

onready var level_text = $Level

func _ready():
	hide()

func update_stats():
	level_text.set_text("Level: " + str(Globals.current_level))

func _on_Exit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Main.tscn")
