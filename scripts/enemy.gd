extends CharacterBody3D

enum State { IDLE, CHASE, ATTACK, DEAD }

@export var speed: float = 3.5
@export var attack_range: float = 1.5
@export var attack_damage: int = 10
@export var fov_degrees: float = 120.0

var _state: State = State.IDLE
var _player: Node3D = null
var _can_attack: bool = true

func _ready() -> void:
	$DetectArea.body_entered.connect(_on_body_entered)
	$DetectArea.body_exited.connect(_on_body_exited)
	$AttackTimer.timeout.connect(_on_attack_timer_timeout)
	# 씬 시작 시 이미 범위 안에 있는 플레이어 감지 (body_entered는 진입 시만 발화)
	await get_tree().physics_frame
	var overlapping: Array = $DetectArea.get_overlapping_bodies()
	for body in overlapping:
		_on_body_entered(body)

func _physics_process(delta: float) -> void:
	match _state:
		State.IDLE:   _process_idle(delta)
		State.CHASE:  _process_chase(delta)
		State.ATTACK: _process_attack(delta)
		State.DEAD:   pass

# IDLE: 매 프레임 능동 시야 스캔. 감지되면 CHASE 전환
func _process_idle(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	velocity += get_gravity() * delta
	move_and_slide()
	_scan_for_player()

func _scan_for_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var target := players[0] as Node3D
	if not target or global_position.distance_to(target.global_position) > 10.0:
		return
	_player = target
	if _can_see_player():
		_state = State.CHASE
	else:
		_player = null

# CHASE: NavigationAgent3D로 플레이어 추격. 공격 범위 내 진입 시 ATTACK 전환
func _process_chase(delta: float) -> void:
	if not is_instance_valid(_player):
		_state = State.IDLE
		return

	var dist := global_position.distance_to(_player.global_position)
	if dist <= attack_range:
		_state = State.ATTACK
		return

	$NavigationAgent3D.target_position = _player.global_position
	var next: Vector3 = $NavigationAgent3D.get_next_path_position()
	var dir := next - global_position
	# NavigationMesh 미베이크 시 next ≈ 현재 위치 → 플레이어 방향 직접 이동으로 폴백
	if dir.length() < 0.1:
		dir = _player.global_position - global_position
	dir.y = 0.0
	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), 10.0 * delta)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	velocity += get_gravity() * delta
	move_and_slide()

# ATTACK: 1초 쿨다운으로 player.take_damage() 호출. 범위 벗어나면 CHASE 복귀
func _process_attack(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	velocity += get_gravity() * delta
	move_and_slide()

	if not is_instance_valid(_player):
		_state = State.IDLE
		return

	if global_position.distance_to(_player.global_position) > attack_range:
		_state = State.CHASE
		return

	if _can_attack:
		_can_attack = false
		_player.take_damage(attack_damage)
		$AttackTimer.start()

func take_damage(_amount: int) -> void:
	if _state == State.DEAD:
		return
	_state = State.DEAD
	set_physics_process(false)
	GameManager.spawn_explosion(global_position)
	queue_free()

func _can_see_player() -> bool:
	if not is_instance_valid(_player):
		return false

	# 시야각 체크 (XZ 평면 기준, Y축 무시)
	var to_player := _player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() < 0.01:
		return true
	to_player = to_player.normalized()

	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var dot := clampf(forward.dot(to_player), -1.0, 1.0)
	if rad_to_deg(acos(dot)) > fov_degrees * 0.5:
		return false

	# 레이캐스트 시야 차단 체크 (벽·장애물이 막으면 false)
	var player_chest := _player.global_position + Vector3(0, 0.9, 0)
	$EyeRay.target_position = $EyeRay.to_local(player_chest)
	$EyeRay.force_raycast_update()
	return not $EyeRay.is_colliding()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and _state == State.IDLE:
		_player = body
		if _can_see_player():
			_state = State.CHASE
		else:
			_player = null

func _on_body_exited(body: Node3D) -> void:
	if body == _player:
		_player = null
		_state = State.IDLE

func _on_attack_timer_timeout() -> void:
	_can_attack = true
