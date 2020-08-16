extends KinematicBody2D

export (float) var WALK_SPEED = 0.1
onready var velocity : Vector2 = Vector2()

enum States {IDLE, WALK}
onready var state = States.IDLE

export (Array, Texture) var idle_frames = []
export (Array, Texture) var walk_frames = []

onready var idle_sprite = $Body/Idle
onready var walk_sprite = $Body/Walk
onready var animation_player = $AnimationPlayer
onready var walk_duration_timer = $WalkDurationTImer
onready var walk_trigger_timer = $WalkTriggerTimer

func _ready():
	randomize()
	var choice = randi() % idle_frames.size()
	idle_sprite.texture = idle_frames[choice]
	walk_sprite.texture = walk_frames[choice]
	
	walk_trigger_timer.wait_time = rand_range(1, 4)
	walk_trigger_timer.start()
	set_state(States.IDLE)

func _physics_process(_delta):
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)
		if velocity.length() > 2:
			velocity = velocity.clamped(2)
	
	state_logic()

func state_logic():
	if state == States.IDLE:
		if velocity.length() > 0:
			set_state(States.WALK)
	elif state == States.WALK:
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

func exit_state(previous_state):
	if previous_state == States.WALK:
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
