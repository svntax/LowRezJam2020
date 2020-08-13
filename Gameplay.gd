extends Node2D

onready var dungeon = null

func _ready():
	generate_dungeon()
	print(dungeon.root.get_cell_position())

# Dungeons are limited to a 10x10 cell size
func generate_dungeon():
	var dungeon_width = 10
	var dungeon_height = 10
	# Place the starting room at a random position
	var starting_room = Vector2(randi() % dungeon_width, randi() % dungeon_height)
	dungeon = GridTree.new(dungeon_width, dungeon_height)
	var start = dungeon.add_starting_room(starting_room.x, starting_room.y)
	# Recursively generate adjacent rooms starting at the root
	var num_rooms = int(rand_range(6, 10))
	dungeon.generate_rooms(num_rooms)
