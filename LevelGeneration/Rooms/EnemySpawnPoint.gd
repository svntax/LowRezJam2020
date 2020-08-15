extends Position2D

export (Array, int, "None", "Normal", "Roller") var spawn_pool = []

func _ready():
	var choice = spawn_pool[randi() % spawn_pool.size()]
	if choice == 1:
		var enemy = Globals.NormalEnemy.instance()
		get_tree().get_root().get_node("Gameplay").add_enemy(enemy)
		enemy.global_position = global_position
	elif choice == 2:
		var enemy = Globals.RollerEnemy.instance()
		get_tree().get_root().get_node("Gameplay").add_enemy(enemy)
		enemy.global_position = global_position
