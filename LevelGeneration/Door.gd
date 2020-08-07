extends Node2D

export (bool) var draw_bottom_line = false

func _ready():
	if draw_bottom_line:
		$Line.show()
