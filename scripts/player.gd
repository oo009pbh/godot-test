extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

const GRAVITY: float = 9.8

func _ready():
	print("Player spawned!")
	
func _process(delta: float):
	pass

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity

	var direction := Vector3.ZERO
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		direction.x += 1.0
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1.0
	if Input.is_action_pressed("ui_down"):
		direction.z += 1.0

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
