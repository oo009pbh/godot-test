# Ch10 — 적 AI & 내비게이션

---

## 개념

### NavigationMesh — 적이 걸을 수 있는 영역 미리 계산

NavigationMesh는 **게임 맵의 "걸을 수 있는 영역 지도"** 다.

**왜 미리 계산(Bake)해야 하나?**
실행 중에 매 프레임 "여기 걸을 수 있나?"를 계산하면 너무 느리다.
그래서 게임 시작 전에 Bake(굽기)를 통해 결과를 미리 저장해둔다.

내비게이션 앱 비유:
- NavigationMesh = 서울 지도. 어디 도로가 있는지 미리 저장된 데이터.
- NavigationAgent3D = 앱의 경로 안내. 지도를 보고 목적지까지 길을 찾아준다.
- 지도 없이는 경로를 못 찾는다 → Bake 없이는 적이 길을 못 찾는다.

```
씬 구조:
NavigationRegion3D       ← "이 영역 안에서 길을 찾아라"
    └── NavigationMesh   ← Bake한 결과 (어디 걸을 수 있는지 기록)
```

**Bake 방법:**
1. 씬에 `NavigationRegion3D` 노드 추가
2. 바닥 `StaticBody3D`가 있는 상태에서
3. `NavigationRegion3D` 선택 → Inspector 상단 **Bake NavigationMesh** 버튼 클릭
4. 에디터에 초록색 메시 = 걸을 수 있는 영역

> 장애물을 추가하거나 바닥 모양을 바꾸면 **다시 Bake** 해야 한다.
> Bake는 에디터에서만 할 수 있는 작업이다.

---

### NavigationAgent3D — A* 길찾기를 대신 처리해주는 노드

`NavigationAgent3D`는 적 캐릭터(`CharacterBody3D`)의 자식으로 붙인다.
A* 알고리즘으로 목적지까지 가장 짧은 경로를 계산하고,
매 프레임 "다음에 어디로 가야 하는지"만 알려준다.

A* 알고리즘 비유:
- 서울에서 부산까지 갈 때, 지도 앱이 "톨게이트 → IC → 휴게소 순서로 가세요"라고 알려주는 것.
- `get_next_path_position()` = 바로 다음 경유지 위치.
- 적은 이 경유지를 향해 조금씩 이동하면 결국 목적지에 도달한다.

```gdscript
extends CharacterBody3D

@export var speed: float = 3.0

@onready var nav_agent = $NavigationAgent3D

var player: Node3D  # 추격할 플레이어 참조

func _ready():
    # 씬 트리에서 플레이어 찾기
    player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
    if player == null:
        return

    # 매 프레임 목적지 갱신 (플레이어가 움직이므로)
    nav_agent.target_position = player.global_position

    # 다음 경유지 위치
    var next_pos = nav_agent.get_next_path_position()

    # 경유지 방향으로 velocity 설정
    var direction = (next_pos - global_position).normalized()
    velocity = direction * speed

    move_and_slide()
```

**`get_next_path_position()`이 필요한 이유:**
목적지(플레이어)를 향해 직선으로 이동하면 벽에 막힌다.
이 함수는 벽을 피해 돌아가는 경로의 다음 지점을 반환한다.

---

### 상태 머신 — 적 AI를 if-else 없이 관리하는 방법

**if-else로 AI를 짜면 어떤 문제가 생기나?**

```gdscript
# 나쁜 예: 조건이 늘어날수록 서로 충돌
func _physics_process(delta):
    if is_player_near and not is_attacking:
        chase()
    elif is_in_attack_range and not is_chasing:
        attack()
    elif hp <= 0 and not is_dead and not is_attacking:
        die()
    # ...조건이 계속 쌓이면 어떤 상태인지 알 수 없어진다
```

**상태 머신(State Machine)으로 짜면:**
"지금 이 적은 딱 하나의 상태에 있다."
상태별 행동을 완전히 분리하므로 코드가 명확해진다.

```
상태 전환 흐름:

  ┌─────────────────────────────────────────┐
  │                                         │
  ▼                                         │
IDLE (대기)                                 │
  │ 플레이어 감지 범위 진입                 │
  ▼                                         │
CHASE (추격) ←──────── 다시 범위 진입      │
  │ 공격 범위 진입                          │
  ▼                                         │
ATTACK (공격)                               │
  │ 공격 끝                                 │
  └─────────────────────────────────────────┘
                    (플레이어 놓치면 IDLE)
                         │
                         ▼
                      DEAD (사망)
```

```gdscript
enum EnemyState { IDLE, CHASE, ATTACK, DEAD }
var state = EnemyState.IDLE

func _physics_process(delta):
    # match = GDScript의 switch문. 현재 상태에 맞는 함수만 실행
    match state:
        EnemyState.IDLE:
            _idle_behavior(delta)
        EnemyState.CHASE:
            _chase_behavior(delta)
        EnemyState.ATTACK:
            _attack_behavior(delta)
        EnemyState.DEAD:
            pass  # 이미 죽었으면 아무것도 안 함

func _idle_behavior(delta):
    velocity = Vector3.ZERO
    move_and_slide()

func _chase_behavior(delta):
    nav_agent.target_position = player.global_position
    var next_pos = nav_agent.get_next_path_position()
    var direction = (next_pos - global_position).normalized()
    velocity = direction * speed
    move_and_slide()

    # 공격 범위 진입 시 상태 전환
    var dist = global_position.distance_to(player.global_position)
    if dist <= attack_range:
        state = EnemyState.ATTACK

func _attack_behavior(delta):
    velocity = Vector3.ZERO
    move_and_slide()
    # 공격 로직은 아래 "공격 쿨다운" 섹션 참조
```

---

### 플레이어 감지 — 두 가지 방법

**방법 1: Area3D — 반경 내 진입 감지 (단순, 빠름)**

Area3D로 구(球)형 감지 범위를 만든다.
플레이어가 범위에 들어오는 순간 신호(Signal)가 발생한다.

```
적 캐릭터
  └── DetectionArea (Area3D)
      └── CollisionShape3D  ← SphereShape3D, radius: 10
```

```gdscript
# DetectionArea의 body_entered 신호를 연결
func _on_detection_area_body_entered(body):
    if body.is_in_group("player"):
        player = body
        state = EnemyState.CHASE  # 즉시 추격 시작

func _on_detection_area_body_exited(body):
    if body.is_in_group("player"):
        state = EnemyState.IDLE   # 범위 벗어나면 대기
        player = null
```

단점: 벽 너머 플레이어도 감지한다. 적이 "텔레파시"로 느낀다.

---

**방법 2: RayCast3D — 시선 차단 확인 (현실적)**

RayCast3D = 눈에 보이지 않는 레이저.
적에서 플레이어 방향으로 레이저를 쏴서, 벽에 막히면 무시한다.

```gdscript
@onready var ray_cast = $RayCast3D

func _check_line_of_sight() -> bool:
    # 레이캐스트 방향을 플레이어 위치로 설정 (로컬 좌표 변환 필요)
    ray_cast.target_position = to_local(player.global_position)
    ray_cast.force_raycast_update()  # 즉시 갱신

    # 레이가 충돌했고, 충돌 대상이 플레이어인지 확인
    if ray_cast.is_colliding():
        return ray_cast.get_collider() == player
    return false
```

`to_local()` 이유: RayCast3D의 `target_position`은 로컬(자기 기준) 좌표다.
플레이어의 월드 좌표를 적 기준 좌표로 변환해야 한다.

---

**방법 3: 시야각(FOV) 추가 — 정면 120도만 감지**

현실 사람처럼 뒤에서 접근하면 감지 못하게 하려면 시야각을 제한한다.

```gdscript
@export var fov_degrees: float = 120.0  # 시야각 (양쪽 합산)

func _is_player_in_fov() -> bool:
    # 적의 정면 방향 (월드 기준)
    var forward = -global_transform.basis.z

    # 플레이어 방향 벡터 (정규화)
    var to_player = (player.global_position - global_position).normalized()

    # 두 벡터 사이 각도를 내적(dot product)으로 계산
    # dot = 1.0: 완전히 같은 방향 (0도)
    # dot = 0.0: 직각 (90도)
    # dot = -1.0: 반대 방향 (180도)
    var dot = forward.dot(to_player)

    # cos(60도) = 0.5 → 정면에서 ±60도 이내 = 전체 120도
    var half_fov = cos(deg_to_rad(fov_degrees / 2.0))
    return dot >= half_fov
```

dot product 비유:
- 두 벡터가 얼마나 같은 방향을 보는지 -1~1 사이 숫자로 나타낸다.
- 1에 가까울수록 같은 방향, -1에 가까울수록 반대 방향.
- 시야각 절반의 cos 값보다 크면 "정면 범위 안"이다.

---

### 공격 쿨다운 — Timer로 공격 간격 제어

공격은 매 프레임 하면 안 된다. 초당 60번 공격하면 게임이 안 된다.
`Timer` 노드 또는 시간 변수로 쿨다운을 구현한다.

**Timer 노드 방법 (권장):**

```
적 캐릭터
  └── AttackTimer (Timer)  ← One Shot: true, Wait Time: 1.0
```

```gdscript
@onready var attack_timer = $AttackTimer
@export var attack_damage: int = 10

var can_attack: bool = true

func _attack_behavior(delta):
    velocity = Vector3.ZERO
    move_and_slide()

    var dist = global_position.distance_to(player.global_position)

    if dist > attack_range:
        # 범위 벗어나면 다시 추격
        state = EnemyState.CHASE
        return

    if can_attack:
        can_attack = false
        attack_timer.start()          # 1초 타이머 시작
        player.take_damage(attack_damage)  # 플레이어에게 데미지

func _on_attack_timer_timeout():
    can_attack = true  # 타이머 끝나면 다시 공격 가능
```

**타이머를 쓰는 이유:**
`delta`를 누적하는 방법도 있지만, Timer 노드는 Godot 시그널과 연결이 간단하고
코드 가독성이 높다.

---

### Signal — 컴포넌트 간 데미지 전달

적이 플레이어에게 데미지를 주는 방법:
직접 `player.hp -= 10`을 쓸 수도 있지만, 신호(Signal)를 쓰면
적이 플레이어의 내부 구조를 몰라도 된다.

```gdscript
# player.gd
signal health_changed(new_health: int)  # 신호 선언

@export var max_health: int = 100
var health: int = max_health

func take_damage(amount: int):
    health -= amount
    health_changed.emit(health)  # UI 등에 알림

    if health <= 0:
        die()

func die():
    queue_free()  # 씬에서 제거
```

```gdscript
# enemy.gd — 플레이어 신호 없이 직접 함수 호출만 해도 됨
# 신호는 UI가 체력 바를 업데이트할 때 활용
player.take_damage(attack_damage)
```

**왜 signal인가?**
플레이어 체력 바(UI), 사망 화면, 사운드 이펙트 — 이 모두가
`health_changed` 신호 하나에 연결하면 된다.
적은 이 연결을 몰라도 된다. 플레이어만 신호를 발생시키면 나머지가 알아서 반응한다.

---

### Group — 노드에 태그 붙이기

Group은 노드에 문자열 태그를 붙이는 기능이다.
씬 트리 어디에 있든, 이름이 뭐든 상관없이 태그로 찾을 수 있다.

```gdscript
# Inspector → Groups 탭에서 추가하거나, 코드로:
func _ready():
    add_to_group("enemy")

# 그룹으로 검색
var all_enemies = get_tree().get_nodes_in_group("enemy")
for enemy in all_enemies:
    enemy.alert()  # 모든 적에게 경보

# 그룹 확인
func _on_area_body_entered(body):
    if body.is_in_group("player"):
        state = EnemyState.CHASE
```

Group vs 직접 참조 비유:
- 직접 참조: 특정 사람 전화번호를 저장한 것. 그 사람이 이름을 바꿔도 번호는 변하지 않지만, 다른 사람에게 쓸 수 없다.
- Group: "팀장"이라는 직책. 팀장이 누가 되든 "팀장에게 보고"가 가능하다.

---

### 적 사망 처리

```gdscript
# enemy.gd
@export var max_hp: int = 30
var hp: int = max_hp

func take_damage(amount: int):
    hp -= amount
    if hp <= 0:
        state = EnemyState.DEAD
        _die()

func _die():
    # 죽는 애니메이션 재생 등 추가 가능
    queue_free()  # 씬에서 제거
```

`queue_free()`는 현재 프레임 처리가 끝난 뒤 삭제한다.
`free()`를 쓰면 즉시 삭제되어, 같은 프레임에 이 노드를 참조하는 코드가 오류를 낼 수 있다.

---

## 실습

### 실습 10-1: NavigationMesh가 있는 레벨

Claude에게 다음 요청:

> "Godot 4에서 내비게이션이 설정된 레벨을 만들어줘.
> - `res://scenes/level.tscn`
> - 바닥 (StaticBody3D, 20x1x20)
> - 장애물 박스 5개 (StaticBody3D, 랜덤 배치)
> - NavigationRegion3D 추가 (NavigationMesh 설정 포함)
> - Bake를 에디터에서 해야 하는 경우 안내해줘"

### 실습 10-2: 플레이어를 쫓는 적

Claude에게 다음 요청:

> "Godot 4에서 플레이어를 추격하는 적 AI를 만들어줘.
> - `res://scenes/enemy.tscn`
> - `res://scripts/enemy.gd`
> - CharacterBody3D 기반, NavigationAgent3D로 플레이어 추격
> - 상태 머신: IDLE / CHASE / ATTACK / DEAD (enum + match)
> - 감지 범위 10m (Area3D 구형), 공격 범위 1.5m
> - Timer 노드로 1초 공격 쿨다운
> - 공격 시 player.take_damage() 호출
> - 플레이어는 'player' 그룹에 있다고 가정"

### 실습 10-3: 시야각 + 시선 차단 추가

Claude에게 다음 요청:

> "enemy.gd에 시야각(FOV) 감지를 추가해줘.
> - 정면 120도 이내에 있는 플레이어만 감지
> - RayCast3D로 벽 너머 플레이어는 무시
> - FOV 각도는 @export로 Inspector에서 조절 가능하게"

### 실습 10-4: 플레이어 체력 시스템

Claude에게 다음 요청:

> "player.gd에 체력 시스템을 추가해줘.
> - @export var max_health: int = 100
> - take_damage(amount: int) 함수
> - health_changed(new_health) Signal 발생
> - hp 0 이하 시 queue_free() (게임 오버는 Ch11에서 구현)"

---

## 확인 포인트

- [ ] NavigationMesh를 Bake해야 길찾기가 동작하는 이유를 설명할 수 있다
- [ ] `NavigationAgent3D`가 경로를 계산하고, `get_next_path_position()`으로 다음 지점을 반환한다는 걸 안다
- [ ] 상태 머신(enum + match)이 if-else 보다 왜 깔끔한지 이해한다
- [ ] Area3D 감지는 빠르지만 벽을 무시하고, RayCast3D는 시선 차단을 확인한다는 차이를 안다
- [ ] dot product로 시야각 범위 안에 있는지 계산하는 방식을 이해한다
- [ ] Timer 노드로 공격 쿨다운을 구현하는 방법을 안다
- [ ] Signal이 적-플레이어 데미지 전달에 왜 유용한지 설명할 수 있다
- [ ] `queue_free()`와 `free()`의 차이를 안다

## 다음 챕터
[Ch11 — 게임 상태 관리](./ch11_game_state.md)
