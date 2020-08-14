extends Node2D

onready var dungeon
onready var map_offset = Vector2(42, 2)
onready var cell_size = Vector2(1, 1)

func set_dungeon_reference(ref):
	dungeon = ref

func _draw():
	if dungeon == null:
		return
	
	for x in range(10):
		for y in range(10):
			var pos = map_offset + Vector2(x*2, y*2)
			var cell = dungeon.grid[x][y]
			if cell != null:
				if cell == dungeon.root:
					draw_rect(Rect2(pos, cell_size), Color.yellow)
				else:
					draw_rect(Rect2(pos, cell_size), Color.green)
				var cell_parent = cell.get_parent()
				if cell_parent != null:
					var dir = cell.get_parent().get_cell_position() - cell.get_cell_position()
					draw_rect(Rect2(pos + dir, cell_size), Color.blue)
			else:
				draw_rect(Rect2(pos, cell_size), Color.gray)

func _process(_delta):
	update()
