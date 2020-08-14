extends Node2D

const ROOM_TILES_SIZE = 16 # In tiles
const ROOM_SIZE = ROOM_TILES_SIZE * 8

const RoomBase = preload("res://LevelGeneration/RoomBase.tscn")
const StartingRoom = preload("res://LevelGeneration/Rooms/StartingRoom.tscn")
const EnemyRooms = [
	preload("res://LevelGeneration/Rooms/EnemiesRoom01.tscn"),
	preload("res://LevelGeneration/Rooms/EnemiesRoom02.tscn"),
]

onready var dungeon_width = 10
onready var dungeon_height = 10

onready var dungeon = null
onready var minimap = $UILayer/Minimap
onready var pause_menu = $UILayer/PauseMenu
onready var player = $Player
onready var rooms = $Rooms
onready var rooms_grid # Grid of room instances

func _ready():
	rooms_grid = []
	for x in range(dungeon_width):
		rooms_grid.append([])
		for _y in range(dungeon_height):
			rooms_grid[x].append(null)
	generate_dungeon()
	minimap.set_dungeon_reference(dungeon)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.show()
		get_tree().paused = true
	if Input.is_action_just_pressed("map_toggle"):
		minimap.visible = !minimap.visible

# Dungeons are limited to a 10x10 cell size
func generate_dungeon():
	# Place the starting room at a random position
	var starting_room = Vector2(randi() % dungeon_width, randi() % dungeon_height)
	dungeon = GridTree.new(dungeon_width, dungeon_height)
	var start = dungeon.add_starting_room(starting_room.x, starting_room.y)
	# Place the player at the starting room
	var spawn_pos = start.get_cell_position() * ROOM_SIZE + Vector2(ROOM_SIZE / 2, ROOM_SIZE / 2)
	player.global_position = spawn_pos
	# Recursively generate adjacent rooms starting at the root
	var num_rooms = int(rand_range(7, 12))
	dungeon.generate_rooms(num_rooms)
	# Actually place the room instances
	place_room_instances()

# Recursively go through the dungeon, starting from the root, and link
# connected rooms together.
func place_room_instances():
	place_room(dungeon.root)

func place_room(current_cell):
	# Instance a room for the current cell
	var base = RoomBase.instance()
	rooms.add_child(base)
	var cell_pos = current_cell.get_cell_position()
	rooms_grid[cell_pos.x][cell_pos.y] = base
	base.position = cell_pos * ROOM_SIZE
	# Connect to parent if applicable
	if current_cell.get_parent_cell() != null:
		var dir = current_cell.get_parent_cell().get_cell_position() - cell_pos
		base.open_passage(dir)
	# Repeat for each neighbor
	for i in range(4):
		var neighbor_cell = current_cell.get_child_towards(Globals.DIRECTIONS[i])
		if neighbor_cell != null:
			# Connect the current cell to the neighbor
			base.open_passage(Globals.DIRECTIONS[i])
			place_room(neighbor_cell)
	
	# Generate the room's layout
	if current_cell == dungeon.root:
		var layout = StartingRoom.instance()
		base.add_child(layout)
	else:
		# Basic enemy room
		var choice = randi() % EnemyRooms.size()
		var layout = EnemyRooms[choice].instance()
		base.add_child(layout)

func get_dungeon():
	return dungeon
