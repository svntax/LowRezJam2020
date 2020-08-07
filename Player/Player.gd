extends KinematicBody2D

onready var speed = 1
const MAX_CHARGE_TIME = 1.0
onready var charge_time = 0
onready var mouse_pressed = false
onready var right_mouse_pressed = false

const POT_SHATTER_THRESHOLD = 0.8

const STOP_THRESHOLD = 0.0015
onready var damping = 0.95
onready var velocity : Vector2 = Vector2()
onready var reflected_velocity : Vector2 = Vector2()

onready var max_hp = 5
onready var hp = max_hp
signal hp_changed(value)

onready var game_root = get_tree().get_root().get_node("Gameplay")
onready var top_animation_player = $TopAnimationPlayer
onready var middle_animation_player = $MiddleAnimationPlayer

func _draw():
	if charge_time > 0:
		draw_rect(Rect2(-6, -5, 12, 1), Color.red)
		draw_rect(Rect2(-6, -5, 12 * (charge_time / MAX_CHARGE_TIME), 1), Color.green)

func _process(_delta):
	update()

func damage(amount : int) -> void:
	hp -= amount
	if hp < 0:
		hp = 0
		# TODO: dead
	emit_signal("hp_changed", hp)

func heal(amount : int) -> void:
	hp += amount
	if hp > max_hp:
		hp = max_hp
	emit_signal("hp_changed", hp)

func _physics_process(delta):
	var collision = move_and_collide(velocity + reflected_velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)
		# Speed scaling for pots
		if collision.collider.is_in_group("Pots"):
			if velocity.length() >= POT_SHATTER_THRESHOLD:
				collision.collider.shatter()
			else:
				# No recoil
				pass
	
	velocity *= damping
	
	# Rough scaling for aniamtion speed based on velocity
	if velocity.length() > 3:
		top_animation_player.playback_speed = 5
		middle_animation_player.playback_speed = 4
	else:
		top_animation_player.playback_speed = 0.2 + 1 * velocity.length() / 0.5
		middle_animation_player.playback_speed = 0.1 + 1 * velocity.length() / 0.5
	
	if velocity.length() <= STOP_THRESHOLD:
		velocity.x = 0
		velocity.y = 0
		if top_animation_player.is_playing():
			top_animation_player.stop()
		if middle_animation_player.is_playing():
			middle_animation_player.stop()
	
	if reflected_velocity.length() > 0:
		reflected_velocity = reflected_velocity.linear_interpolate(Vector2.ZERO, 0.12)
	
	# Holding click charges the power bar
	if mouse_pressed:
		charge_time += delta
		if charge_time > MAX_CHARGE_TIME:
			charge_time = MAX_CHARGE_TIME
	
	if Input.is_action_just_pressed("right_click"):
		mouse_pressed = false
		right_mouse_pressed = true
		charge_time = 0
	if Input.is_action_just_released("right_click"):
		right_mouse_pressed = false
	
	if !right_mouse_pressed and Input.is_action_just_pressed("click"):
		mouse_pressed = true
	if !right_mouse_pressed and mouse_pressed and Input.is_action_just_released("click"):
		mouse_pressed = false
		launch()
		charge_time = 0
	
	# TODO: debug healing, remove later
	if Input.is_action_just_pressed("ui_page_down"):
		damage(1)
	if Input.is_action_just_pressed("ui_page_up"):
		heal(1)

# Shoot the player away from the mouse
func launch() -> void:
	var mouse_pos = get_global_mouse_position()
	var vel = mouse_pos.direction_to(global_position)
	var power = speed
	var percent = charge_time / MAX_CHARGE_TIME
	# Rough accelerated growth
	if charge_time < MAX_CHARGE_TIME * 0.1:
		power *= 0.5
	elif charge_time < MAX_CHARGE_TIME * 0.6:
		power *= 0.8 + percent
	elif charge_time < MAX_CHARGE_TIME:
		power *= 1.5 + percent
	else:
		# Max power
		power *= 2 + percent
	vel *= power
	set_velocity(vel.x, vel.y)
	if randi() % 2 == 0:
		top_animation_player.play("clockwise")
	else:
		top_animation_player.play_backwards("clockwise")
	if randi() % 2 == 0:
		middle_animation_player.play("clockwise")
	else:
		middle_animation_player.play_backwards("clockwise")

func set_velocity(x : float, y : float) -> void:
	velocity.x = x
	velocity.y = y
