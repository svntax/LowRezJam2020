extends "res://Enemies/PoolBallEnemy.gd"

const CHARGE_SPEED = 2.8

onready var player_detect = $PlayerDetect
onready var damage_cooldown_timer = $DamageCooldownTimer
onready var player_nearby = false
onready var damage_ready = true

func state_logic():
	.state_logic()
	
	if state == States.IDLE or state == States.WALK:
		if should_attack():
			set_state(States.CHARGE)

func enter_state(new_state):
	match new_state:
		States.CHARGE:
			set_velocity(Vector2.ZERO)
			animation_player.play("charge")
	
	.enter_state(new_state)

func should_attack():
	if not damage_cooldown_timer.is_stopped():
		return false
	
	var player = get_tree().get_nodes_in_group("Players")[0]
	if player_nearby and Globals.get_cell_position(self) == Globals.get_cell_position(player):
		return true
	return false

func charge_towards_player():
	var player = get_tree().get_nodes_in_group("Players")[0]
	var dir = global_position.direction_to(player.global_position)
	set_velocity(dir * CHARGE_SPEED)

# Override, deals damage if high enough velocity
func can_deal_damage() -> bool:
	return damage_ready and velocity.length() >= DASH_MIN_SPEED

func deal_damage(other):
	.deal_damage(other)
	damage_ready = false
	damage_cooldown_timer.start()

func _on_PlayerDetect_body_entered(body):
	player_nearby = true

func _on_PlayerDetect_body_exited(body):
	player_nearby = false

func _on_AnimationPlayer_animation_finished(anim):
	._on_AnimationPlayer_animation_finished(anim)
	if anim == "charge":
		charge_towards_player()
		set_state(States.ROLL)

func _on_DamageCooldownTimer_timeout():
	damage_ready = true
