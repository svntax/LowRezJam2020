class_name GridTree
extends Reference

# Tree data structure for the dungeon using a grid of cells.

const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var grid : Array
var root
var width
var height

func _init(w: int, h: int):
	width = w
	height = h
	grid = []
	for x in range(width):
		grid.append([])
		for y in range(height):
			grid[x].append(null)

func add_starting_room(x: int, y: int):
	root = GridCell.new(x, y)
	grid[x][y] = root
	return root

func generate_rooms(num_rooms: int):
	var count = 0
	# TODO: algorithm

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
		target_pos = current_pos + DIRECTIONS[dir]
		if not valid_cell_pos(target_pos):
			continue
		if grid[target_pos.x][target_pos.y] == null:
			empty_neighbor_found = true
			break
	
	if empty_neighbor_found:
		var new_cell = GridCell.new(target_pos.x, target_pos.y)
		grid[target_pos.x][target_pos.y] = new_cell
		new_cell.set_parent(current_cell)
		current_cell.set_child_from_direction(new_cell, dir)
		return new_cell
	else:
		return null

func get_room(x: int, y: int):
	return grid[x][y]

func valid_cell_pos(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height
