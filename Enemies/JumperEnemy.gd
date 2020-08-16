extends "res://Enemies/PoolBallEnemy.gd"

onready var player_detect = $PlayerDetect
onready var damage_cooldown_timer = $DamageCooldownTimer
onready var shockwave_area = $ShockwaveArea
onready var jump_tween = $JumpTween
onready var collision_reset_timer = $CollisionResetTimer

onready var player_nearby = false
onready var damage_ready = true
onready var original_layer
onready var original_mask

func _ready():
	original_layer = collision_layer
	original_mask = collision_mask
	player_detect.connect("body_entered", self, "_on_PlayerDetect_body_entered")
	player_detect.connect("body_exited", self, "_on_PlayerDetect_body_exited")

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
			trail_particles.emitting = false
			dash_particles.emitting = false
		States.JUMP:
			collision_layer = 0
			collision_mask = 0
			trail_particles.emitting = false
			dash_particles.emitting = false
			set_velocity(Vector2.ZERO)
			animation_player.play("jump")
			jump_to_player()
	
	.enter_state(new_state)

func exit_state(previous_state):
	.exit_state(previous_state)
	if previous_state == States.JUMP:
		collision_reset_timer.start()

func should_attack():
	if not damage_cooldown_timer.is_stopped():
		return false
	
	var player = get_tree().get_nodes_in_group("Players")[0]
	if player_nearby and Globals.get_cell_position(self) == Globals.get_cell_position(player):
		return true
	return false

# Override, deals damage only when slamming the ground
func can_deal_damage() -> bool:
	return damage_ready and animation_player.current_animation == "jump"

func deal_damage(other):
	.deal_damage(other)
	damage_ready = false
	damage_cooldown_timer.start()

func jump_to_player():
	var player = get_tree().get_nodes_in_group("Players")[0]
	var target_pos = Vector2(player.global_position.x, player.global_position.y)
	jump_tween.stop_all()
	jump_tween.interpolate_property(self, "global_position", global_position, target_pos, \
		0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	jump_tween.interpolate_property(body, "scale", body.scale, Vector2(1.5, 1.5), \
		0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	jump_tween.interpolate_property(body, "position", body.position, Vector2(0, -12), \
		0.4, Tween.TRANS_EXPO, Tween.EASE_OUT)
	jump_tween.start()

func slam_ground():
	for body in shockwave_area.get_overlapping_bodies():
		if body.has_method("knockback"):
			var dir = global_position.direction_to(body.global_position)
			if dir.is_equal_approx(Vector2.ZERO):
				dir = Vector2(1, 0).rotated(rand_range(0, 2*PI))
			body.knockback(dir * 1.5)
			if body.is_in_group("Players"):
				if can_deal_damage():
					deal_damage(body)

func _on_PlayerDetect_body_entered(body):
	if body.is_in_group("Players"):
		player_nearby = true

func _on_PlayerDetect_body_exited(body):
	if body.is_in_group("Players"):
		player_nearby = false

func _on_AnimationPlayer_animation_finished(anim):
	._on_AnimationPlayer_animation_finished(anim)
	if anim == "charge":
		set_state(States.JUMP)
	elif anim == "jump":
		set_state(States.ROLL)

func _on_DamageCooldownTimer_timeout():
	damage_ready = true

func _on_CollisionReset_timeout():
	collision_layer = original_layer
	collision_mask = original_mask
