extends KinematicBody2D

const STOP_THRESHOLD = 0.0015
const WALK_SPEED = 0.1
onready var damping = 0.95
onready var velocity : Vector2 = Vector2()
onready var reflected_velocity : Vector2 = Vector2()

enum States {IDLE, WALK, CHARGE, ROLL}
onready var state = States.IDLE

onready var roll_sprite = $Roll
onready var idle_sprite = $Idle
onready var walk_sprite = $Walk
onready var animation_player = $AnimationPlayer
onready var walk_duration_timer = $WalkDurationTImer
onready var walk_trigger_timer = $WalkTriggerTimer

func _ready():
	walk_trigger_timer.wait_time = rand_range(1, 4)
	walk_trigger_timer.start()
	set_state(States.IDLE)

func _physics_process(_delta):
	var collision = move_and_collide(velocity + reflected_velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)
	
	if state == States.ROLL:
		velocity *= damping
	
	if velocity.length() <= STOP_THRESHOLD:
		velocity.x = 0
		velocity.y = 0
	
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
	elif state == States.CHARGE:
		pass
	elif state == States.ROLL:
		if velocity.x == 0 and velocity.y == 0:
			set_state(States.IDLE)

func enter_state(new_state):
	match new_state:
		States.IDLE:
			set_velocity(Vector2.ZERO)
			if animation_player.current_animation != "idle":
				animation_player.play("idle", -1, 0.5)
		States.WALK:
			if animation_player.current_animation != "walk":
				animation_player.play("walk")
			walk_to_random()
		States.CHARGE:
			set_velocity(Vector2.ZERO)
		States.ROLL:
			animation_player.stop()
			roll_sprite.show()
			idle_sprite.hide()
			walk_sprite.hide()

func exit_state(previous_state):
	if previous_state == States.ROLL:
		roll_sprite.hide()

func set_state(new_state):
	var previous_state = state
	exit_state(previous_state)
	state = new_state
	enter_state(new_state)

func set_velocity(vel : Vector2) -> void:
	velocity.x = vel.x
	velocity.y = vel.y

func knockback(impulse : Vector2) -> void:
	velocity += impulse
	set_state(States.ROLL)

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
