extends Node2D

#const BG_COLOR = Color("180d2f")
const DOOR_COLOR = Color("8b97b6")
const ROOM_COLOR = Color("ffffff")
const BLINK_COLOR = Color("ecab11")
const EXIT_COLOR = Color("08b23b")
onready var player_color = ROOM_COLOR

export (NodePath) var player_path = ""
onready var player = null

onready var dungeon
onready var map_offset = Vector2(42, 4)
onready var cell_size = Vector2(1, 1)
onready var exit_cell = null

func _ready():
	player = get_node_or_null(player_path)

func set_dungeon_reference(ref):
	dungeon = ref

func set_exit_cell(cell):
	exit_cell = cell

func _draw():
	if dungeon == null or !is_instance_valid(dungeon):
		return
	
	#draw_rect(Rect2(map_offset.x - 1, map_offset.y - 1, 21, 21), BG_COLOR)
	for x in range(10):
		for y in range(10):
			var pos = map_offset + Vector2(x*2, y*2)
			var cell = dungeon.grid[x][y]
			if cell != null:
#				if cell == dungeon.root:
#					draw_rect(Rect2(pos, cell_size), Color.yellow)
				if cell == exit_cell:
					draw_rect(Rect2(pos, cell_size), EXIT_COLOR)
				elif cell.was_visited():
					draw_rect(Rect2(pos, cell_size), ROOM_COLOR)
					var cell_parent = cell.get_parent_cell()
					if cell_parent != null:
						var dir = cell.get_parent_cell().get_cell_position() - cell.get_cell_position()
						draw_rect(Rect2(pos + dir, cell_size), DOOR_COLOR)
	
	if player != null:
		draw_object_in_minimap(player)

func draw_object_in_minimap(obj):
	var cell_pos = Vector2(int(obj.global_position.x / 128), int(obj.global_position.y / 128))
	draw_rect(Rect2(map_offset + cell_pos*2, cell_size), player_color)

func _process(_delta):
	update()

func _on_BlinkTimer_timeout():
	if player_color == ROOM_COLOR:
		player_color = BLINK_COLOR
	else:
		player_color = ROOM_COLOR
