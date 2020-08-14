extends Node2D

const ROOM_TILES_SIZE = 16 # In tiles
const ROOM_SIZE = ROOM_TILES_SIZE * 8

onready var dungeon = null
onready var minimap = $UILayer/Minimap
onready var pause_menu = $UILayer/PauseMenu
onready var player = $Player

func _ready():
	generate_dungeon()
	minimap.set_dungeon_reference(dungeon)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.show()
		get_tree().paused = true

# Dungeons are limited to a 10x10 cell size
func generate_dungeon():
	var dungeon_width = 10
	var dungeon_height = 10
	# Place the starting room at a random position
	var starting_room = Vector2(randi() % dungeon_width, randi() % dungeon_height)
	dungeon = GridTree.new(dungeon_width, dungeon_height)
	var start = dungeon.add_starting_room(starting_room.x, starting_room.y)
	var spawn_pos = start.get_cell_position() * ROOM_SIZE + Vector2(ROOM_SIZE / 2, ROOM_SIZE / 2)
	#player.global_position = spawn_pos
	# Recursively generate adjacent rooms starting at the root
	var num_rooms = int(rand_range(8, 12))
	dungeon.generate_rooms(num_rooms)

func get_dungeon():
	return dungeon
