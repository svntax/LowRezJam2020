extends Node2D

onready var north_open = false
onready var south_open = false
onready var west_open = false
onready var east_open = false

onready var north_door = $NorthDoor
onready var south_door = $SouthDoor
onready var west_door = $WestDoor
onready var east_door = $EastDoor
onready var base_tiles = $BaseTiles

func _ready():
	north_door.hide()
	south_door.hide()
	west_door.hide()
	east_door.hide()

func open_passage(dir: Vector2):
	if dir == Vector2.UP:
		north_open = true
		north_door.show()
		base_tiles.set_cell(7, 0, -1)
		base_tiles.set_cell(7, 1, -1)
		base_tiles.set_cell(8, 0, -1)
		base_tiles.set_cell(8, 1, -1)
	elif dir == Vector2.DOWN:
		south_open = true
		south_door.show()
		base_tiles.set_cell(7, 14, -1)
		base_tiles.set_cell(7, 15, -1)
		base_tiles.set_cell(8, 14, -1)
		base_tiles.set_cell(8, 15, -1)
	elif dir == Vector2.LEFT:
		west_open = true
		west_door.show()
		base_tiles.set_cell(0, 7, -1)
		base_tiles.set_cell(1, 7, -1)
		base_tiles.set_cell(0, 8, -1)
		base_tiles.set_cell(1, 8, -1)
	elif dir == Vector2.RIGHT:
		east_open = true
		east_door.show()
		base_tiles.set_cell(14, 7, -1)
		base_tiles.set_cell(15, 7, -1)
		base_tiles.set_cell(14, 8, -1)
		base_tiles.set_cell(15, 8, -1)
