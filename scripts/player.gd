extends CharacterBody3D

enum State { IDLE, WALKING, JUMPING }

@export var speed: float = 5.0
@export var run_speed: float = 10.0
@export var jump_velocity: float = 5.0
@export var mouse_sensitivity: float = 0.003
@export var attack_damage: int = 30
@export var footstep_sound: AudioStream
@export var jump_sound: AudioStream
@export var land_sound: AudioStream

const FOOTSTEP_INTERVAL: float = 0.4

var _state: State = State.IDLE
var _materials: Array[StandardMaterial3D] = []
var _jumps_remaining: int = 0
var _footstep_timer: float = 0.0
var _was_on_floor: bool = false

signal health_changed(new_health: int)

@export var max_health: int = 100
var _health: int = 100

@onready var _attack_ray: RayCast3D = $CameraPivot/SpringArm3D/Camera3D/AttackRay
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _vignette: ColorRect = $DamageVignette/VignetteRect
@onready var _footstep_player: AudioStreamPlayer = $FootstepPlayer

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
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_attack()

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
	_update_footstep(delta)

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
		_play_sound(jump_sound)

func _update_footstep(delta: float) -> void:
	var on_floor := is_on_floor()
	if on_floor and not _was_on_floor:
		_play_sound(land_sound)
	_was_on_floor = on_floor

	if on_floor and velocity.length() > 0.5:
		_footstep_timer -= delta
		if _footstep_timer <= 0.0:
			_play_sound(footstep_sound)
			_footstep_timer = FOOTSTEP_INTERVAL
	else:
		_footstep_timer = 0.0

func _play_sound(stream: AudioStream) -> void:
	if stream == null:
		return
	_footstep_player.stream = stream
	_footstep_player.pitch_scale = 1.0 + randf_range(-0.1, 0.1)
	_footstep_player.play()

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

func _attack() -> void:
	if _attack_ray.is_colliding():
		var target := _attack_ray.get_collider()
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	GameManager.take_damage(amount)
	_flash_red()
	_shake_camera()
	_flash_vignette()

func _flash_red() -> void:
	var prev_mat: Material = $MeshInstance3D.get_active_material(0)
	var flash_mat := StandardMaterial3D.new()
	flash_mat.albedo_color = Color(1.0, 0.1, 0.1)
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1, 0, 0)
	$MeshInstance3D.set_surface_override_material(0, flash_mat)
	await get_tree().create_timer(0.15).timeout
	$MeshInstance3D.set_surface_override_material(0, prev_mat)

func _shake_camera() -> void:
	var orig_h := _camera.h_offset
	var orig_v := _camera.v_offset
	var elapsed := 0.0
	while elapsed < 0.2:
		_camera.h_offset = orig_h + randf_range(-0.3, 0.3)
		_camera.v_offset = orig_v + randf_range(-0.3, 0.3)
		elapsed += get_process_delta_time()
		await get_tree().process_frame
	_camera.h_offset = orig_h
	_camera.v_offset = orig_v

func _flash_vignette() -> void:
	var tween := create_tween()
	tween.tween_property(_vignette, "color:a", 0.4, 0.05)
	tween.tween_property(_vignette, "color:a", 0.0, 0.3)

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
