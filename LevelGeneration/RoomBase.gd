extends Node2D

onready var north_open = false
onready var south_open = false
onready var west_open = false
onready var east_open = false

onready var north_door = $NorthDoor
onready var south_door = $SouthDoor
onready var west_door = $WestDoor
onready var east_door = $EastDoor
onready var base_tiles = $BaseTiles
onready var layout_root = $LayoutRoot
onready var enemy_detect = $EnemyDetect

onready var valid_doors = []
onready var locked_until_enemies_defeated = false

func _ready():
	north_door.hide()
	south_door.hide()
	west_door.hide()
	east_door.hide()

func lock_doors():
	for door in valid_doors:
		door.lock_door()

func unlock_doors():
	for door in valid_doors:
		door.unlock_door()

# Adds a created layout instance to this room and deletes the current layout if it exists.
func add_layout(layout_instance):
	if layout_root.get_child_count() > 0:
		# Delete existing layout
		for layout in layout_root.get_children():
			layout.queue_free()
	layout_root.add_child(layout_instance)

func open_passage(dir: Vector2):
	if dir == Vector2.UP:
		north_open = true
		north_door.show()
		base_tiles.set_cell(7, 0, -1)
		base_tiles.set_cell(7, 1, -1)
		base_tiles.set_cell(8, 0, -1)
		base_tiles.set_cell(8, 1, -1)
		valid_doors.append(north_door)
	elif dir == Vector2.DOWN:
		south_open = true
		south_door.show()
		base_tiles.set_cell(7, 14, -1)
		base_tiles.set_cell(7, 15, -1)
		base_tiles.set_cell(8, 14, -1)
		base_tiles.set_cell(8, 15, -1)
		valid_doors.append(south_door)
	elif dir == Vector2.LEFT:
		west_open = true
		west_door.show()
		base_tiles.set_cell(0, 7, -1)
		base_tiles.set_cell(1, 7, -1)
		base_tiles.set_cell(0, 8, -1)
		base_tiles.set_cell(1, 8, -1)
		valid_doors.append(west_door)
	elif dir == Vector2.RIGHT:
		east_open = true
		east_door.show()
		base_tiles.set_cell(14, 7, -1)
		base_tiles.set_cell(15, 7, -1)
		base_tiles.set_cell(14, 8, -1)
		base_tiles.set_cell(15, 8, -1)
		valid_doors.append(east_door)

func _on_PlayerDetect_body_entered(body):
	if body.is_in_group("Players"):
		if require_enemies_defeated() and get_enemy_count() > 0:
			lock_doors()

func require_enemies_defeated():
	return locked_until_enemies_defeated

func set_lock_on_enter(flag: bool):
	locked_until_enemies_defeated = flag

func get_enemy_count():
	var count = 0
	for each in enemy_detect.get_overlapping_bodies():
		if each.is_in_group("Enemies"):
			count += 1
	return count
