class_name GridCell
extends Reference

# Node structure for the grid tree that contains only 4 children

var child_up = null
var child_down = null
var child_left = null
var child_right = null
var parent = null

# Cell position in the dungeon
var x: int
var y: int
var visited = false

func _init(cell_x: int, cell_y: int):
	x = cell_x
	y = cell_y

func has_empty_neighbor() -> bool:
	return child_up == null or child_down == null or child_left == null or child_right == null

func add_child_towards(new_child, dir: Vector2):
	if new_child == parent:
		return
	
	if dir == Vector2.UP:
		child_up = new_child
	elif dir == Vector2.DOWN:
		child_down = new_child
	elif dir == Vector2.LEFT:
		child_left = new_child
	elif dir == Vector2.RIGHT:
		child_right = new_child

func get_cell_position():
	return Vector2(x, y)

func get_child_towards(dir: Vector2):
	if dir == Vector2.UP:
		return child_up
	elif dir == Vector2.DOWN:
		return child_down
	elif dir == Vector2.LEFT:
		return child_left
	elif dir == Vector2.RIGHT:
		return child_right

func was_visited() -> bool:
	return visited

func set_parent_cell(other):
	parent = other

func get_parent_cell():
	return parent
