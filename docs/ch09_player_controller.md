# Ch09 — 플레이어 컨트롤러

---

## 개념

### 3인칭 플레이어의 구조
```
Player (CharacterBody3D)
├── MeshInstance3D          ← 플레이어 모델
├── CollisionShape3D        ← 충돌 범위 (CapsuleShape3D)
├── CameraPivot (Node3D)    ← 카메라 수직 회전 축
│   └── SpringArm3D         ← 카메라-벽 충돌 방지
│       └── Camera3D        ← 실제 카메라
└── AnimationPlayer         ← 애니메이션 (옵션)
```

### 이동 방향과 카메라 방향 동기화
카메라가 보는 방향으로 이동해야 자연스럽다.

```gdscript
# 카메라 방향을 기준으로 이동 벡터 변환
var cam_basis = camera.global_basis
var move_direction = (cam_basis * Vector3(input.x, 0, input.y)).normalized()
move_direction.y = 0  # 수직 방향은 중력이 처리

velocity.x = move_direction.x * SPEED
velocity.z = move_direction.z * SPEED
```

### 플레이어가 이동 방향으로 회전
```gdscript
# 이동 방향으로 부드럽게 회전
if move_direction.length() > 0.1:
    var target_angle = atan2(move_direction.x, move_direction.z)
    rotation.y = lerp_angle(rotation.y, target_angle, 10.0 * delta)
```

### 입력 시스템 (InputMap)
`project.godot`에 InputMap을 정의해두면 코드에서 키 이름으로 참조:

```gdscript
# project.godot에 "move_forward", "move_back", "move_left", "move_right", "jump" 등록
var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
```

**InputMap에 등록하는 법 (에디터):**
`Project → Project Settings → Input Map` 탭

**Claude가 직접 project.godot에 추가해줄 수 있다.**

### 카메라 마우스 컨트롤
```gdscript
func _input(event):
    if event is InputEventMouseMotion:
        # 좌우 회전: Player 전체 회전
        rotate_y(-event.relative.x * mouse_sensitivity)
        # 상하 회전: CameraPivot만 회전
        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        # 상하 각도 제한
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.2, 0.4)
```

### 상태 머신 (State Machine) 기초
복잡한 플레이어 동작은 상태로 구분:

```
Idle  →  (이동 입력)  →  Walking
Walking  →  (공격 키)  →  Attacking
Walking  →  (Space)  →  Jumping
Jumping  →  (바닥 닿음)  →  Idle
```

```gdscript
enum State { IDLE, WALKING, JUMPING, ATTACKING }
var current_state = State.IDLE
```

---

## 실습

### 실습 9-1: 완성된 3인칭 플레이어
Claude에게 다음 요청:

> "Godot 4에서 3인칭 플레이어를 완성해줘.
> - 씬: `res://scenes/player.tscn`
> - 스크립트: `res://scripts/player.gd`
> - 구조: CharacterBody3D > MeshInstance3D(캡슐), CollisionShape3D(캡슐), CameraPivot > SpringArm3D(길이 4) > Camera3D
> - WASD 이동 (카메라 방향 기준)
> - 마우스로 카메라 회전 (마우스 캡처: Input.set_mouse_mode)
> - Space 점프
> - 이동 방향으로 플레이어 회전 (lerp)
> - 이동속도 5, 달리기(Shift) 10, 점프력 5
> - InputMap도 project.godot에 추가해줘"

### 실습 9-2: 이동 속도 조절 실험
플레이어 스크립트의 `@export var speed` 값을 Inspector에서 바꿔가며 느낌 차이 확인.

### 실습 9-3: 더블 점프 추가
Claude에게 다음 요청:

> "플레이어 스크립트에 더블 점프를 추가해줘.
> 공중에 있을 때 Space를 한 번 더 누르면 한 번 더 점프할 수 있어.
> 바닥에 닿으면 더블 점프 횟수가 리셋돼야 해."

---

## 확인 포인트
- [ ] CameraPivot이 왜 별도로 있는지 안다 (상하 회전 분리)
- [ ] SpringArm3D의 역할을 안다
- [ ] 이동 방향이 카메라 기준으로 변환되어야 하는 이유를 안다
- [ ] InputMap에 키를 등록하는 방법을 안다

## 다음 챕터
[Ch10 — 적 AI & 내비게이션](./ch10_enemy_ai.md)
