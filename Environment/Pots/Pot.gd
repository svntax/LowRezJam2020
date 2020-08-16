extends KinematicBody2D

const PotNormalShard = preload("res://Environment/Pots/PotNormalShard.tscn")
const HeartPickup = preload("res://LevelGeneration/Items/HeartPickup.tscn")

const STOP_THRESHOLD = 0.0015
onready var damping = 0.95
onready var velocity : Vector2 = Vector2()
onready var reflected_velocity : Vector2 = Vector2()

onready var sprite_normal = $Pot
onready var sprite_broken = $Broken
onready var collision_shape = $Collision

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

func drop_heart():
	var heart = HeartPickup.instance()
	get_parent().add_child(heart)
	heart.global_position = global_position

func shatter() -> void:
	var roll = randf()
	if roll < 0.2:
		drop_heart()
	sprite_normal.hide()
	collision_shape.disabled = true
	for _i in range(2):
		var shard = PotNormalShard.instance()
		add_child(shard)
		var vel = Vector2(0.7, 0).rotated(rand_range(0, 2*PI))
		shard.set_velocity(vel)
