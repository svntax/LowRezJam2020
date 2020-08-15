extends Node

const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var current_level = 1

func get_cell_position(obj: Node2D):
	var cell_pos = Vector2(int(obj.global_position.x / 128), int(obj.global_position.y / 128))
	return cell_pos
