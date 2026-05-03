# Ch10 — 적 AI & 내비게이션

---

## 개념

### NavigationMesh — 적이 걸을 수 있는 영역 정의
```
NavigationRegion3D       ← 내비게이션 가능 영역
    └── NavigationMesh   ← 실제 메시 데이터 (Bake로 생성)
```

**NavigationMesh Bake 과정:**
1. `NavigationRegion3D` 노드를 씬에 추가
2. 바닥 StaticBody3D가 있는 상태에서
3. `NavigationRegion3D` 선택 → Inspector 상단 **Bake NavigationMesh** 버튼 클릭
4. 초록색 메시가 걸을 수 있는 영역으로 표시됨

### NavigationAgent3D — 적 캐릭터 길찾기

```gdscript
extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

func _ready():
    nav_agent.target_position = player.global_position

func _physics_process(delta):
    var next_pos = nav_agent.get_next_path_position()
    var direction = (next_pos - global_position).normalized()
    velocity = direction * speed
    move_and_slide()
```

### 상태 머신 (State Machine) - 적 AI 패턴

```
Idle (대기)
    → 플레이어 감지 시 → Chase (추격)
Chase (추격)
    → 공격 범위 진입 시 → Attack (공격)
    → 플레이어 놓쳤을 때 → Idle
Attack (공격)
    → 쿨다운 끝 → Chase (다시 추격)
```

```gdscript
enum EnemyState { IDLE, CHASE, ATTACK, DEAD }
var state = EnemyState.IDLE

func _physics_process(delta):
    match state:
        EnemyState.IDLE:
            _idle_behavior(delta)
        EnemyState.CHASE:
            _chase_behavior(delta)
        EnemyState.ATTACK:
            _attack_behavior(delta)
```

### 플레이어 감지 — Area3D 또는 RayCast3D

**방법 1: Area3D (시야 범위)**
```gdscript
# 구형 Area3D로 반경 감지
func _on_detection_area_body_entered(body):
    if body.is_in_group("player"):
        state = EnemyState.CHASE
```

**방법 2: RayCast3D (시선 확인)**
```gdscript
# 벽 너머의 플레이어는 무시
ray_cast.target_position = to_local(player.global_position)
if ray_cast.is_colliding() and ray_cast.get_collider() == player:
    state = EnemyState.CHASE
```

### Group — 노드 태그 시스템
```gdscript
# Node Inspector → Groups 탭에서 추가 또는 코드로:
add_to_group("enemy")
add_to_group("player")

# 그룹으로 찾기
var enemies = get_tree().get_nodes_in_group("enemy")

# 그룹 체크
if body.is_in_group("player"):
    take_damage()
```

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
> - CharacterBody3D 기반
> - NavigationAgent3D로 플레이어 추격
> - 상태: IDLE / CHASE / ATTACK
> - 감지 범위 10m (Area3D 구형)
> - 공격 범위 1.5m, 공격 딜레이 1초
> - 공격 시 플레이어 health 감소 (Signal로 전달)
> - 플레이어는 'player' 그룹에 있다고 가정해줘"

### 실습 10-3: 시야각 추가
Claude에게 다음 요청:

> "enemy.gd에 시야각(FOV) 감지를 추가해줘.
> 정면 120도 이내에 있는 플레이어만 감지하게 해줘.
> RayCast3D로 벽 너머 플레이어는 무시해줘."

---

## 확인 포인트
- [ ] NavigationMesh를 Bake해야 길찾기가 동작하는 것을 안다
- [ ] NavigationAgent3D와 CharacterBody3D의 역할 구분을 안다
- [ ] 상태 머신 패턴이 왜 AI에 유용한지 안다
- [ ] `is_in_group()`으로 노드를 식별하는 방법을 안다

## 다음 챕터
[Ch11 — 게임 상태 관리](./ch11_game_state.md)
