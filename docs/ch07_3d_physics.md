# Ch07 — 3D 물리 & 충돌

---

## 개념

### 물리 Body 종류 비교

| Body | 움직임 | 충돌 | 용도 |
|------|--------|------|------|
| `StaticBody3D` | 안 움직임 | 받음 | 바닥, 벽, 장애물 |
| `CharacterBody3D` | 코드로 직접 제어 | 받음 | 플레이어, 적 |
| `RigidBody3D` | 물리 엔진이 자동 제어 | 받음 | 상자, 공, 파편 |
| `Area3D` | 움직임 가능 | 감지만 함 | 아이템 획득 범위, 데미지 존 |

### CollisionShape3D
**반드시 Body에 붙여야 충돌이 동작한다.**

```
StaticBody3D (또는 CharacterBody3D)
└── CollisionShape3D
    └── Shape 속성: BoxShape3D / CapsuleShape3D / SphereShape3D
```

**Shape 선택 기준:**
- 박스 → `BoxShape3D`
- 캐릭터(사람) → `CapsuleShape3D` (성능 좋음)
- 공 → `SphereShape3D`
- 복잡한 형태 → `ConcavePolygonShape3D` (성능 나쁨, 바닥에만 사용)

### CharacterBody3D 이동 패턴

```gdscript
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta):
    # 중력 적용
    if not is_on_floor():
        velocity += get_gravity() * delta

    # 점프
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # 이동
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity.x = input_dir.x * SPEED
    velocity.z = input_dir.y * SPEED

    move_and_slide()  # ← 이 한 줄이 이동 + 충돌 처리를 모두 함
```

`move_and_slide()`는 `velocity`를 바탕으로 이동하면서 충돌 처리를 자동으로 한다.

### Layer & Mask — 충돌 그룹
어떤 오브젝트끼리 충돌할지 설정.

```
Layer 1: World (바닥, 벽)
Layer 2: Player
Layer 3: Enemy
Layer 4: Projectile (총알)

총알 설정:
  - Collision Layer: 4 (나는 4번이다)
  - Collision Mask: 1, 3 (1번, 3번과 충돌한다 = 바닥, 적과 충돌)
```

Inspector에서 `Collision` 섹션의 Layer/Mask를 체크박스로 설정한다.

### Area3D — 트리거
충돌하지 않고 "겹침"만 감지:

```gdscript
extends Area3D

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body.is_in_group("player"):
        # 아이템 획득
        queue_free()  # 이 노드를 씬에서 제거
```

---

## 실습

### 실습 7-1: 중력과 충돌이 있는 기본 씬
Claude에게 다음 요청:

> "Godot 4에서 물리 실험 씬을 만들어줘. `res://scenes/physics_test.tscn`으로 저장해줘.
> - 바닥: StaticBody3D + BoxMesh(10x0.5x10) + CollisionShape3D
> - 떨어지는 박스: RigidBody3D + BoxMesh(1x1x1) + CollisionShape3D, 바닥에서 y=5 위치에 배치
> - 카메라: 씬 전체를 볼 수 있는 위치
> - 실행하면 박스가 중력으로 떨어져서 바닥에 닿는 씬"

### 실습 7-2: 걸어다니는 플레이어
Claude에게 다음 요청:

> "Godot 4에서 WASD로 걸어다니고 Space로 점프하는 CharacterBody3D 플레이어를 만들어줘.
> - `res://scenes/player.tscn`
> - `res://scripts/player.gd`
> - 플레이어 모양: CapsuleShape3D (높이 1.8), 위에 MeshInstance3D CapsuleMesh
> - 이동속도 5, 점프력 5, Godot 기본 중력 사용
> - 조작 InputMap에 move_forward/backward/left/right/jump 추가해줘 (project.godot 수정)"

### 실습 7-3: 아이템 획득 영역
Claude에게 다음 요청:

> "실습 7-2 씬에 Area3D 아이템을 추가해줘.
> - 빛나는 구 모양 (MeshInstance3D + SphereMesh)
> - 플레이어가 닿으면 콘솔에 'Item collected!' 출력 후 사라짐
> - Area3D의 Collision Layer/Mask는 Player와만 반응하게 설정해줘"

---

## 확인 포인트
- [ ] `StaticBody3D`, `CharacterBody3D`, `RigidBody3D`의 차이를 안다
- [ ] `CollisionShape3D`가 없으면 충돌이 안 된다는 것을 안다
- [ ] `move_and_slide()`가 무슨 역할을 하는지 안다
- [ ] `Area3D`와 `CollisionShape3D`의 차이를 안다

## 다음 챕터
[Ch08 — 3D 애셋 가져오기](./ch08_3d_assets.md)
