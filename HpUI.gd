extends Control

onready var hearts_front = $HeartsFront
onready var hearts_back = $HeartsBack

func update_hp(amount : int) -> void:
	var count = 0
	for heart in hearts_front.get_children():
		if count < amount:
			heart.show()
		else:
			heart.hide()
		count += 1

func _on_Player_hp_changed(value : int) -> void:
	update_hp(value)
