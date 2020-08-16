extends Node2D

onready var bg_theme = $BgTheme

func _ready():
	randomize()
	# Default size 512x512
	OS.window_size = Vector2(512, 512)
	# Center the window after resizing
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	bg_theme.play()
	Globals.current_level = 1

func _on_Start_pressed():
	get_tree().change_scene("res://Gameplay.tscn")

func _on_Exit_pressed():
	get_tree().quit()
