extends KinematicBody2D

const STOP_THRESHOLD = 0.0015
onready var damping = 0.85
onready var velocity : Vector2 = Vector2()
onready var reflected_velocity : Vector2 = Vector2()

func _ready():
	var choice = randi() % 3 + 1
	get_node("Sprite" + str(choice)).show()
	get_node("Collision" + str(choice)).disabled = false
	$LifeTimer.start()

func _physics_process(_delta):
	var collision = move_and_collide(velocity + reflected_velocity)
	if collision:
		velocity = velocity.bounce(collision.normal)
	
	velocity *= damping
	
	if velocity.length() <= STOP_THRESHOLD:
		velocity.x = 0
		velocity.y = 0
	
	if reflected_velocity.length() > 0:
		reflected_velocity = reflected_velocity.linear_interpolate(Vector2.ZERO, 0.12)

func set_velocity(vel : Vector2) -> void:
	velocity = vel

func _on_LifeTimer_timeout():
	queue_free()
