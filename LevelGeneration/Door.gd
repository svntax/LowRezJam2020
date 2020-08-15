extends Node2D

export (bool) var draw_bottom_line = false

onready var locked = false
onready var locked_sprite = $Locked
onready var lock_body = $Locked/LockBody

func _ready():
	if draw_bottom_line:
		$Line.show()
	unlock_door()

func lock_door():
	locked_sprite.show()
	lock_body.collision_layer = 1
	lock_body.collision_mask = 1

func unlock_door():
	locked_sprite.hide()
	lock_body.collision_layer = 0
	lock_body.collision_mask = 0
