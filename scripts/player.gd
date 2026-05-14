extends CharacterBody3D

enum State { IDLE, WALKING, JUMPING }

@export var speed: float = 5.0
@export var run_speed: float = 10.0
@export var jump_velocity: float = 5.0
@export var mouse_sensitivity: float = 0.003

var _state: State = State.IDLE
var _materials: Array[StandardMaterial3D] = []
var _jumps_remaining: int = 0

signal health_changed(new_health: int)

@export var max_health: int = 100
var _health: int = 100

func _ready():
	add_to_group("player")
	$CameraPivot/SpringArm3D.add_excluded_object(get_rid())
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var red := StandardMaterial3D.new()
	red.albedo_color = Color.RED
	var green := StandardMaterial3D.new()
	green.albedo_color = Color.GREEN
	var blue := StandardMaterial3D.new()
	blue.albedo_color = Color.BLUE
	_materials = [red, green, blue]
	$MeshInstance3D.set_surface_override_material(0, _materials[0])

func _input(event: InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		$CameraPivot.rotation.y -= event.relative.x * mouse_sensitivity
		$CameraPivot.rotation.x -= event.relative.y * mouse_sensitivity
		$CameraPivot.rotation.x = clamp($CameraPivot.rotation.x, deg_to_rad(-60), deg_to_rad(20))

func _physics_process(delta: float):
	_update_state()

	match _state:
		State.IDLE:
			_process_idle(delta)
		State.WALKING:
			_process_walking(delta)
		State.JUMPING:
			_process_jumping(delta)

	move_and_slide()

# 물리 결과(is_on_floor, velocity)를 보고 다음 상태를 결정
func _update_state() -> void:
	if is_on_floor():
		_jumps_remaining = 2
		if _get_input_dir() != Vector2.ZERO:
			_state = State.WALKING
		else:
			_state = State.IDLE
	else:
		_state = State.JUMPING

# IDLE: 서 있는 상태. 입력: WASD(→ WALKING 전환), Space(점프)
func _process_idle(delta: float) -> void:
	velocity += get_gravity() * delta
	velocity.x = 0.0
	velocity.z = 0.0
	_try_jump()

# WALKING: 이동 중. 입력: WASD(방향·속도), Shift(달리기), Space(점프)
func _process_walking(delta: float) -> void:
	velocity += get_gravity() * delta
	_apply_movement(delta)
	_try_jump()

# JUMPING: 공중. 입력: WASD(공중 방향 유지), Space(더블 점프, 잔여 횟수 있을 때)
func _process_jumping(delta: float) -> void:
	velocity += get_gravity() * delta
	_apply_movement(delta)
	_try_jump()

func _try_jump() -> void:
	if Input.is_action_just_pressed("jump") and _jumps_remaining > 0:
		velocity.y = jump_velocity
		_jumps_remaining -= 1
		var random_mat := _materials[randi() % _materials.size()]
		$MeshInstance3D.set_surface_override_material(0, random_mat)

func _apply_movement(delta: float) -> void:
	var input_dir := _get_input_dir()
	if input_dir == Vector2.ZERO:
		velocity.x = 0.0
		velocity.z = 0.0
		return

	var current_speed := run_speed if Input.is_action_pressed("move_run") else speed
	var forward: Vector3 = -$CameraPivot.global_transform.basis.z
	var right: Vector3 = $CameraPivot.global_transform.basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	var direction: Vector3 = forward * (-input_dir.y) + right * input_dir.x
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	var target_angle := atan2(-direction.x, -direction.z)
	var old_y := rotation.y
	rotation.y = lerp_angle(rotation.y, target_angle, 10.0 * delta)
	$CameraPivot.rotation.y += old_y - rotation.y

func take_damage(amount: int) -> void:
	_health = max(0, _health - amount)
	health_changed.emit(_health)
	if _health <= 0:
		queue_free()

func _get_input_dir() -> Vector2:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		dir.x += 1.0
	if Input.is_action_pressed("move_forward"):
		dir.y -= 1.0
	if Input.is_action_pressed("move_backward"):
		dir.y += 1.0
	return dir.normalized() if dir != Vector2.ZERO else Vector2.ZERO
