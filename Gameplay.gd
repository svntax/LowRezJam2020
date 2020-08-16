extends Node2D

const ROOM_TILES_SIZE = 16 # In tiles
const ROOM_SIZE = ROOM_TILES_SIZE * 8

const RoomBase = preload("res://LevelGeneration/RoomBase.tscn")
const StartingRoom = preload("res://LevelGeneration/Rooms/StartingRoom.tscn")
const ExitRoom = preload("res://LevelGeneration/Rooms/ExitRoom.tscn")
const EnemyRooms = [
	preload("res://LevelGeneration/Rooms/EnemiesRoom01.tscn"),
	preload("res://LevelGeneration/Rooms/EnemiesRoom02.tscn"),
	preload("res://LevelGeneration/Rooms/EnemiesRoom03.tscn"),
	preload("res://LevelGeneration/Rooms/EnemiesRoom04.tscn"),
	preload("res://LevelGeneration/Rooms/EnemiesRoom05.tscn"),
	preload("res://LevelGeneration/Rooms/EnemiesRoom06.tscn"),
	preload("res://LevelGeneration/Rooms/EnemiesRoom07.tscn"),
]
const ItemRooms = [
	preload("res://LevelGeneration/Rooms/ItemsRoom01.tscn"),
	preload("res://LevelGeneration/Rooms/ItemsRoom02.tscn"),
]
onready var enemy_room_index = 0
onready var enemy_room_choices = []

onready var dungeon_width = 10
onready var dungeon_height = 10
onready var exit_cell = null

onready var game_state = "NORMAL"
onready var screenshake_active = false

onready var dungeon = null
onready var minimap = $UILayer/Minimap
onready var pause_menu = $UILayer/PauseMenu
onready var game_over_menu = $UILayer/GameOverMenu
onready var player = $Player
onready var rooms = $Rooms
onready var rooms_grid = [] # Grid of room instances
onready var enemies_root = $Enemies
onready var theme_intro = $ThemeIntro
onready var theme_loop = $ThemeLoop

func _ready():
	theme_intro.play()
	start_level()

func start_level():
	player.set_velocity(0, 0)
	player.reset_camera()
	dungeon = null
	rooms_grid.clear()
	for each in rooms.get_children():
		each.queue_free()
	for each in enemies_root.get_children():
		each.queue_free()
	for x in range(dungeon_width):
		rooms_grid.append([])
		for _y in range(dungeon_height):
			rooms_grid[x].append(null)
	
	# Makes sure that enemy room layouts don't repeat
	enemy_room_choices.clear()
	for i in range(EnemyRooms.size()):
		enemy_room_choices.append(i)
	enemy_room_choices.shuffle()
	enemy_room_index = 0
	
	generate_dungeon()
	minimap.set_dungeon_reference(dungeon)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		pause_menu.show()
		get_tree().paused = true
	if Input.is_action_just_pressed("map_toggle"):
		minimap.visible = !minimap.visible
	
	# Room visit checking
	if dungeon != null and is_instance_valid(dungeon):
		var cell_pos = Globals.get_cell_position(player)
		dungeon.grid[cell_pos.x][cell_pos.y].visited = true

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
		var layout = null
		var roll = randf()
		if current_cell in dungeon.get_dead_end_rooms():
			# Dead-end rooms have a higher chance of being item rooms
			var item_room_chance = 0.4
			if player.hp < 3:
				item_room_chance = 0.8
			if roll < item_room_chance:
				# Item room
				var i = randi() % ItemRooms.size()
				layout = ItemRooms[i].instance()
			else:
				# Enemy room
				var i = get_next_enemy_room_layout()
				layout = EnemyRooms[i].instance()
		else:
			if roll < 0.08:
				# Item room
				var i = randi() % ItemRooms.size()
				layout = ItemRooms[i].instance()
			else:
				# Enemy room
				var i = get_next_enemy_room_layout()
				layout = EnemyRooms[i].instance()
		base.add_layout(layout)
		base.set_lock_on_enter(true)

# Returns the next enemy room layout out of the current list of
# enemy room layouts, shuffled in order to minimize repetition
func get_next_enemy_room_layout():
	var current_choice = enemy_room_choices[enemy_room_index % enemy_room_choices.size()]
	enemy_room_index += 1
	if enemy_room_index > enemy_room_choices.size():
		enemy_room_index = 0
		enemy_room_choices.shuffle()
	
	return current_choice

func exit_reached():
	# TODO: show some menu/animation first before moving to next level
	Globals.current_level += 1
	start_level()

func get_dungeon():
	return dungeon

func add_enemy(enemy_instance):
	enemies_root.add_child(enemy_instance)

func check_enemy_room_complete(cell_x, cell_y):
	var room = rooms_grid[cell_x][cell_y]
	for i in range(3):
		yield(get_tree().create_timer(0.5), "timeout")
		if room.get_enemy_count() <= 0:
			room.unlock_doors()
			return

func game_over():
	game_state == "GAME_OVER"
	get_tree().paused = true
	game_over_menu.update_stats()
	game_over_menu.show()

func _on_ThemeIntro_finished():
	theme_loop.play()

func shake_camera(duration, magnitude, frequency):
	if game_state != "NORMAL":
		player.camera.offset = Vector2()
		return
	
	if not screenshake_active:
		screenshake_active = true
		var start_time = OS.get_ticks_msec()
		var _time = start_time
		
		while _time < start_time + (duration * 1000) and game_state == "NORMAL":
			# Update _time to current ticks
			_time = OS.get_ticks_msec()
			
			var offset = Vector2()
			offset.x = rand_range(-magnitude, magnitude)
			offset.y = rand_range(-magnitude, magnitude)
			player.camera.offset = offset
			
			# Pause the loop based on frequency.
			yield(get_tree().create_timer(1 / float(frequency)), "timeout")
		
		player.camera.offset = Vector2()
		screenshake_active = false
