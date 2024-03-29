extends KinematicBody2D

const MAX_SPEED = 4
const DASH_MIN_SPEED = 0.8
const STOP_THRESHOLD = 0.0015
export (float) var WALK_SPEED = 0.1
export (float) var damping = 0.955
onready var velocity : Vector2 = Vector2()
onready var reflected_velocity : Vector2 = Vector2()

enum States {IDLE, WALK, CHARGE, ROLL, POP, FALLING, JUMP}
onready var state = States.IDLE

onready var game_root = get_tree().get_root().get_node("Gameplay")
onready var body = $Body
onready var roll_sprite = $Body/Roll
onready var idle_sprite = $Body/Idle
onready var walk_sprite = $Body/Walk
onready var head_pop_sprite = $Body/HeadPop
onready var flash_sprite = $Body/Flash
onready var animation_player = $AnimationPlayer
onready var walk_duration_timer = $WalkDurationTImer
onready var walk_trigger_timer = $WalkTriggerTimer
onready var shadow_roll_sprite = $ShadowRoll
onready var shadow_standing_sprite = $ShadowStanding
onready var trail_particles = $TrailParticles
onready var dash_particles = $DashParticles
onready var falling_timer = $FallingTimer
onready var falling_sfx = $FallingSound
onready var charge_up_sfx = $ChargeSound

func _ready():
	walk_trigger_timer.wait_time = rand_range(1, 4)
	walk_trigger_timer.start()
	set_state(States.IDLE)

func _physics_process(_delta):
	# Don't move if not in the same room as the player
	if Globals.get_cell_position(game_root.player) != Globals.get_cell_position(self):
		velocity = Vector2.ZERO
	
	if state == States.FALLING:
		collision_layer = 0
		collision_mask = 0
	
	var collision = move_and_collide(velocity + reflected_velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if velocity.length() > MAX_SPEED:
			velocity = velocity.clamped(MAX_SPEED)
		# Speed scaling for pots
		if collision.collider.is_in_group("Pots"):
			if velocity.length() >= DASH_MIN_SPEED:
				collision.collider.shatter()
			else:
				# No recoil
				pass
		elif collision.collider.has_method("knockback"):
			collision.collider.knockback(velocity * 0.8)
			if collision.collider.is_in_group("Players"):
				if can_deal_damage():
					deal_damage(collision.collider)
	
	if state == States.ROLL:
		velocity *= damping
	if is_standing():
		shadow_roll_sprite.hide()
		shadow_standing_sprite.show()
	elif state == States.FALLING:
		shadow_roll_sprite.hide()
		shadow_standing_sprite.hide()
	else:
		shadow_roll_sprite.show()
		shadow_standing_sprite.hide()
	
	if velocity.length() <= STOP_THRESHOLD:
		velocity.x = 0
		velocity.y = 0
	
	# Dash effect logic
	if velocity.length() >= DASH_MIN_SPEED:
		if can_deal_damage():
			flash_sprite.modulate.a = 89.0 / 255.0
			trail_particles.emitting = false
			dash_particles.emitting = true
		else:
			trail_particles.emitting = true
			dash_particles.emitting = false
			flash_sprite.modulate.a = 0
	elif velocity.length() >= DASH_MIN_SPEED / 2:
		trail_particles.emitting = true
		dash_particles.emitting = false
		flash_sprite.modulate.a = 0
	else:
		trail_particles.emitting = false
		dash_particles.emitting = false
		flash_sprite.modulate.a = 0
	
	state_logic()
	
	if reflected_velocity.length() > 0:
		reflected_velocity = reflected_velocity.linear_interpolate(Vector2.ZERO, 0.12)

func state_logic():
	if state == States.IDLE:
		if velocity.length() > 0:
			set_state(States.WALK)
	elif state == States.WALK:
		if velocity.x == 0 and velocity.y == 0:
			set_state(States.IDLE)
	elif state == States.ROLL:
		if velocity.x == 0 and velocity.y == 0:
			set_state(States.POP)

func enter_state(new_state):
	match new_state:
		States.IDLE:
			if head_pop_sprite.visible:
				idle_sprite.show()
				head_pop_sprite.hide()
			set_velocity(Vector2.ZERO)
			if animation_player.current_animation != "idle":
				animation_player.play("idle", -1, 0.5)
		States.WALK:
			if head_pop_sprite.visible:
				walk_sprite.show()
				head_pop_sprite.hide()
			if animation_player.current_animation != "walk":
				animation_player.play("walk")
			walk_to_random()
		States.ROLL:
			animation_player.stop()
			roll_sprite.show()
			idle_sprite.hide()
			walk_sprite.hide()
			head_pop_sprite.hide()
			flash_sprite.modulate.a = 0
		States.POP:
			animation_player.play("pop_out")
		States.FALLING:
			falling_timer.start()
			collision_layer = 0
			collision_mask = 0
			trail_particles.emitting = false
			dash_particles.emitting = false
			flash_sprite.modulate.a = 0
			set_velocity(Vector2.ZERO)
			falling_sfx.play()
			animation_player.play("falling")
			idle_sprite.hide()
			roll_sprite.show()
			walk_sprite.hide()
			head_pop_sprite.hide()

func exit_state(previous_state):
	if previous_state == States.ROLL:
		roll_sprite.hide()
	elif previous_state == States.WALK:
		walk_sprite.frame = 0
	elif previous_state == States.IDLE:
		idle_sprite.frame = 0

func set_state(new_state):
	var previous_state = state
	exit_state(previous_state)
	state = new_state
	enter_state(new_state)

func set_velocity(vel : Vector2) -> void:
	velocity.x = vel.x
	velocity.y = vel.y

func knockback(impulse : Vector2) -> void:
	if state == States.FALLING:
		return
	
	velocity += impulse
	set_state(States.ROLL)

func dash_damage():
	# Deal damage if knocked back with dash attack?
	pass

func can_deal_damage() -> bool:
	return false

func deal_damage(other):
	if other.has_method("damage"):
		other.damage(1)

func walk_to_random():
	var angle = rand_range(0, 2 * PI)
	var dir = Vector2(WALK_SPEED, 0).rotated(angle)
	set_velocity(dir)
	walk_duration_timer.wait_time = rand_range(0.5, 2)
	walk_duration_timer.start()

func _on_WalkTriggerTimer_timeout():
	if state == States.IDLE:
		set_state(States.WALK)
	walk_trigger_timer.start()

func _on_WalkDurationTImer_timeout():
	if state == States.WALK:
		set_state(States.IDLE)

func fall_in_hole():
	set_state(States.FALLING)

func is_standing():
	return state == States.IDLE or state == States.WALK 

func die():
	if !is_queued_for_deletion():
		var cell_pos = Globals.get_cell_position(self)
		game_root.check_enemy_room_complete(cell_pos.x, cell_pos.y)
		queue_free()

func play_charge_up_sound():
	charge_up_sfx.play()

func _on_AnimationPlayer_animation_finished(anim):
	if anim == "pop_out":
		set_state(States.IDLE)
	elif anim == "falling":
		hide()
		#die()

func _on_FallingTimer_timeout():
	hide()
	#die()

func state_as_string(s):
	match s:
		States.ROLL:
			return "ROLL"
		States.IDLE:
			return "IDLE"
		States.WALK:
			return "WALK"
		States.CHARGE:
			return "CHARGE"
		States.FALLING:
			return "FALLING"
		States.JUMP:
			return "JUMP"
		States.POP:
			return "POP"

func _on_FallingSound_finished():
	die()
