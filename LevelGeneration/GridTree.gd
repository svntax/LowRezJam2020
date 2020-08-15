class_name GridTree
extends Reference

# Tree data structure for the dungeon using a grid of cells.

var grid : Array
var root
var width
var height
var room_count = 0
var room_limit = 10 # Default
var deepest_rooms = []
var farthest_depth_level = 0
var dead_end_rooms = []

func _init(w: int, h: int):
	width = w
	height = h
	grid = []
	for x in range(width):
		grid.append([])
		for _y in range(height):
			grid[x].append(null)

func add_starting_room(x: int, y: int):
	root = GridCell.new(x, y)
	grid[x][y] = root
	return root

func generate_rooms(num_rooms: int):
	room_limit = num_rooms
	generate_neighbors(root, 0)

# Finds the deepest rooms in the grid and stores them in an array
# Assumes that generate_rooms() has already been called
func detect_deepest_rooms():
	_find_deepest_rooms(root, 0)

func _find_deepest_rooms(cell, depth):
	if cell == null:
		return
	if depth == farthest_depth_level:
		deepest_rooms.append(cell)
	else:
		for i in range(4):
			var neighbor = cell.get_child_towards(Globals.DIRECTIONS[i])
			_find_deepest_rooms(neighbor, depth + 1)

func get_deepest_rooms() -> Array:
	return deepest_rooms

func get_farthest_depth_level():
	return farthest_depth_level

func generate_neighbors(current_room, depth_level: int):
	# Keep track of the depth level of the deepest cells
	if farthest_depth_level < depth_level:
		farthest_depth_level = depth_level
	
	if room_count >= room_limit:
		return
	if current_room == null:
		return
	
	var neighbor1 = add_random_neighbor(current_room)
	var neighbor2 = add_random_neighbor(current_room)
	generate_neighbors(neighbor1, depth_level + 1)
	generate_neighbors(neighbor2, depth_level + 1)

# Adds a new cell at a random direction if possible.
# Returns the newly created cell or null if failed.
func add_random_neighbor(current_cell):
	var current_pos = current_cell.get_cell_position()
	var target_pos = null
	var dir = null
	var empty_neighbor_found = false
	var dir_indexes = [0, 1, 2, 3]
	dir_indexes.shuffle()
	for i in range(dir_indexes.size()):
		dir = dir_indexes[i]
		target_pos = current_pos + Globals.DIRECTIONS[dir]
		if not valid_cell_pos(target_pos):
			continue
		if grid[target_pos.x][target_pos.y] == null:
			empty_neighbor_found = true
			break
	
	if empty_neighbor_found:
		var new_cell = GridCell.new(target_pos.x, target_pos.y)
		grid[target_pos.x][target_pos.y] = new_cell
		new_cell.set_parent_cell(current_cell)
		current_cell.add_child_towards(new_cell, Globals.DIRECTIONS[dir])
		room_count += 1
		return new_cell
	else:
		return null

func get_room(x: int, y: int):
	return grid[x][y]

func valid_cell_pos(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height
