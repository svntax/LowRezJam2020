extends Node2D

const ROOM_TILES_SIZE = 16 # In tiles
const ROOM_SIZE = ROOM_TILES_SIZE * 8

const RoomBase = preload("res://LevelGeneration/RoomBase.tscn")
const StartingRoom = preload("res://LevelGeneration/Rooms/StartingRoom.tscn")
const ExitRoom = preload("res://LevelGeneration/Rooms/ExitRoom.tscn")
const EnemyRooms = [
	preload("res://LevelGeneration/Rooms/EnemiesRoom01.tscn"),
	preload("res://LevelGeneration/Rooms/EnemiesRoom02.tscn"),
]

onready var dungeon_width = 10
onready var dungeon_height = 10
onready var exit_cell = null

onready var dungeon = null
onready var minimap = $UILayer/Minimap
onready var pause_menu = $UILayer/PauseMenu
onready var player = $Player
onready var rooms = $Rooms
onready var rooms_grid = [] # Grid of room instances
onready var enemies_root = $Enemies

func _ready():
	start_level()

func start_level():
	player.set_velocity(0, 0)
	player.reset_camera()
	dungeon = null
	rooms_grid.clear()
	for each in rooms.get_children():
		each.queue_free()
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
	dungeon.detect_deepest_rooms()
	yield(get_tree(), "physics_frame")
	# Actually place the room instances
	place_room_instances()

# Recursively go through the dungeon, starting from the root, and link
# connected rooms together.
func place_room_instances():
	var deepest_rooms = dungeon.get_deepest_rooms()
	var choice = randi() % deepest_rooms.size()
	exit_cell = deepest_rooms[choice]
	# Place the starting room and enemy rooms
	place_room(dungeon.root)
	# Place the exit room randomly at one of the deepest rooms
	var cell_pos = exit_cell.get_cell_position()
	var layout = ExitRoom.instance()
	rooms_grid[cell_pos.x][cell_pos.y].add_layout(layout)
	minimap.set_exit_cell(exit_cell)

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
		base.add_layout(layout)
	elif current_cell == exit_cell:
		# Don't generate the layout for the exit room, it will be done separately
		pass
	else:
		# Basic enemy room
		var choice = randi() % EnemyRooms.size()
		var layout = EnemyRooms[choice].instance()
		base.add_layout(layout)

func exit_reached():
	# TODO: show some menu/animation first before moving to next level
	Globals.current_level += 1
	start_level()

func get_dungeon():
	return dungeon

func add_enemy(enemy_instance):
	enemies_root.add_child(enemy_instance)
