extends KinematicBody2D

onready var speed = 1
const MAX_CHARGE_TIME = 1.0
onready var charge_time = 0
onready var mouse_pressed = false

onready var damping = 0.95
onready var velocity : Vector2 = Vector2()
onready var reflected_velocity : Vector2 = Vector2()

onready var game_root = get_tree().get_root().get_node("Gameplay")

func _draw():
	if charge_time > 0:
		draw_rect(Rect2(-6, -5, 12, 1), Color.red)
		draw_rect(Rect2(-6, -5, 12 * (charge_time / MAX_CHARGE_TIME), 1), Color.green)

func _process(_delta):
    update()

func _physics_process(delta):
	var collision = move_and_collide(velocity + reflected_velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)
	
	velocity *= damping
	
	if reflected_velocity.length() > 0:
		reflected_velocity = reflected_velocity.linear_interpolate(Vector2.ZERO, 0.12)
	
	# Holding click charges the power bar
	if mouse_pressed:
		charge_time += delta
		if charge_time > MAX_CHARGE_TIME:
			charge_time = MAX_CHARGE_TIME
	
	if Input.is_action_just_pressed("click"):
		mouse_pressed = true
	if Input.is_action_just_released("click"):
		mouse_pressed = false
		launch()
		charge_time = 0

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

func set_velocity(x : float, y : float) -> void:
	velocity.x = x
	velocity.y = y
