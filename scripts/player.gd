extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 5.0
@export var mouse_sensitivity: float = 0.003

var _materials: Array[StandardMaterial3D] = []

func _ready():
	add_to_group("player")
	$CameraPivot/SpringArm3D.add_excluded_object(get_rid())

	var red := StandardMaterial3D.new()
	red.albedo_color = Color.RED

	var green := StandardMaterial3D.new()
	green.albedo_color = Color.GREEN

	var blue := StandardMaterial3D.new()
	blue.albedo_color = Color.BLUE

	_materials = [red, green, blue]
	$MeshInstance3D.set_surface_override_material(0, _materials[0])

func _input(event: InputEvent):
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_rotate"):
		$CameraPivot.rotation.y -= event.relative.x * mouse_sensitivity
		$CameraPivot.rotation.x -= event.relative.y * mouse_sensitivity
		$CameraPivot.rotation.x = clamp($CameraPivot.rotation.x, deg_to_rad(-60), deg_to_rad(20))

func _physics_process(delta: float):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		var random_mat := _materials[randi() % _materials.size()]
		$MeshInstance3D.set_surface_override_material(0, random_mat)

	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1.0
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1.0
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1.0

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		var forward: Vector3 = -$CameraPivot.global_transform.basis.z
		var right: Vector3 = $CameraPivot.global_transform.basis.x
		forward.y = 0.0
		right.y = 0.0
		forward = forward.normalized()
		right = right.normalized()
		var direction: Vector3 = forward * (-input_dir.y) + right * input_dir.x
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
