# Ch09 — 플레이어 컨트롤러

---

## 개념

### 3인칭 플레이어란?

1인칭과 3인칭의 차이는 카메라 위치뿐이다:

| 시점 | 카메라 위치 | 플레이어 모델 보임 |
|------|------------|----------------|
| 1인칭 | 플레이어 눈 안 | 자기 몸 안 보임 |
| 3인칭 | 플레이어 뒤·위 | 보임 |

3인칭이 복잡한 이유:
- 카메라가 플레이어를 따라다녀야 한다
- 마우스로 카메라를 회전하면, 이동 방향도 그에 맞게 바뀌어야 한다
- 벽이나 물체가 있으면 카메라가 그 안으로 뚫고 들어가면 안 된다

---

### 3인칭 플레이어의 씬 구조

```
Player (CharacterBody3D)           ← 물리·이동 담당
├── MeshInstance3D                 ← 눈에 보이는 캡슐 모델
├── CollisionShape3D               ← 물리 충돌 범위
├── CameraPivot (Node3D)           ← 카메라 상하 회전 축
│   └── SpringArm3D                ← 카메라-벽 충돌 방지 팔
│       └── Camera3D               ← 실제 카메라
└── AnimationPlayer                ← 애니메이션 (선택)
```

각 노드가 있는 이유:

**CameraPivot (Node3D)**
플레이어의 좌우 회전과 카메라의 상하 회전을 분리하기 위해 중간 노드를 둔다.
- Player 본체는 좌우(Y축) 회전만 처리한다 — 캐릭터가 옆으로 도는 것
- CameraPivot은 상하(X축) 회전만 처리한다 — 카메라가 위아래를 보는 것

만약 CameraPivot 없이 Camera3D를 Player에 직접 붙이면, 위를 바라볼 때
플레이어 몸도 같이 위로 기울어진다. 게임에서 캐릭터가 위아래로 몸을 기울이는 건 어색하다.

**SpringArm3D**
카메라를 플레이어 뒤에 일정 거리만큼 띄워두는 역할이다.
단순히 카메라 위치를 뒤로 옮기는 것과 다른 점: 중간에 벽이 있으면 팔을 자동으로 줄인다.

```
벽 없을 때:  Player ──────────── Camera  (SpringLength = 4)
벽 있을 때:  Player ──── 벽 / Camera     (팔이 줄어들어 카메라가 벽 앞으로 당겨짐)
```

셀카봉(모노포드)과 같다. 셀카봉을 뻗었다가 무언가에 걸리면 더 이상 못 뻗는 것처럼,
SpringArm3D도 경로에 장애물이 있으면 그 앞에서 카메라를 멈춘다.

---

### 이동 방향과 카메라 방향 동기화

이것이 3인칭 컨트롤러에서 가장 핵심적인 부분이다.

**문제:**
W 키를 누르면 어느 방향으로 이동해야 하는가?
- 플레이어 기준 앞? → 카메라를 왼쪽으로 돌렸는데 W를 눌러도 플레이어가 원래 방향으로 가서 어색하다
- 카메라 기준 앞? → 카메라가 보는 방향으로 이동. 자연스럽다.

대부분의 3인칭 게임은 카메라 기준으로 이동한다.

**해결 방법:**

입력값(`input.x`, `input.y`)은 [-1, 1] 범위의 수평 방향 숫자다.
이것을 카메라의 방향 기준으로 변환한다.

```gdscript
# 1. 입력 읽기 (input.x = 좌우, input.y = 앞뒤)
var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

# 2. 카메라의 현재 방향 정보 가져오기
var cam_basis = camera.global_basis
# cam_basis.x = 카메라의 오른쪽 방향 벡터
# cam_basis.z = 카메라의 앞쪽 방향 벡터

# 3. 입력을 카메라 방향 기준으로 변환
var move_direction = (cam_basis * Vector3(input.x, 0, input.y)).normalized()

# 4. y(수직) 성분 제거: 카메라가 위를 봐도 위로 날아가면 안 됨
move_direction.y = 0

# 5. velocity에 적용
velocity.x = move_direction.x * SPEED
velocity.z = move_direction.z * SPEED
```

**현실 비유:**
카메라가 북동쪽을 보고 있을 때 W를 누르면 북동쪽으로 이동해야 한다.
`cam_basis * Vector3(0, 0, 1)` 이 계산이 "카메라 좌표계의 앞쪽 → 월드 좌표계의 북동쪽"으로 변환해준다.

---

### 플레이어가 이동 방향으로 회전

이동 방향으로 캐릭터가 몸을 돌려야 자연스럽다.
급격하게 돌리면 어색하므로 `lerp_angle`로 부드럽게 보간한다.

```gdscript
if move_direction.length() > 0.1:  # 이동 중일 때만 회전 (정지 시 원래 방향 유지)
    # atan2: 방향 벡터 → 각도(라디안) 변환
    var target_angle = atan2(move_direction.x, move_direction.z)

    # lerp_angle: 현재 각도 → 목표 각도로 부드럽게 보간
    # 10.0 * delta: 1초에 10라디안 속도로 회전 (숫자가 클수록 빠름)
    rotation.y = lerp_angle(rotation.y, target_angle, 10.0 * delta)
```

**`lerp_angle`이 일반 `lerp`와 다른 점:**
각도는 360° = 0°다. 350°에서 10°로 회전할 때,
- 일반 lerp: 350 → 180 → 10 (거꾸로 돌아감)
- lerp_angle: 350 → 360/0 → 10 (가까운 방향으로 돌아감)

**`move_direction.length() > 0.1` 조건의 이유:**
정지하면 입력이 0이 되고 `atan2(0, 0)`은 0이 나와서 캐릭터가 항상 북쪽을 본다.
이동 중일 때만 회전하면 정지 시 마지막 방향을 유지한다.

---

### 마우스 캡처 (Mouse Capture)

FPS·TPS 게임에서 마우스가 화면 밖으로 나가면 안 된다.
Godot에서는 `Input.set_mouse_mode()`로 제어한다.

```gdscript
func _ready():
    # 마우스를 화면 중앙에 고정하고 커서를 숨김
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    # ESC로 마우스 해제
    if event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
```

| 모드 | 커서 보임 | 화면 이탈 가능 | 용도 |
|------|---------|-------------|------|
| `MOUSE_MODE_VISIBLE` | O | O | 기본 상태, UI |
| `MOUSE_MODE_HIDDEN` | X | O | 커서만 숨김 |
| `MOUSE_MODE_CAPTURED` | X | X | FPS/TPS 게임 |
| `MOUSE_MODE_CONFINED` | O | X | 전략 게임 |

---

### 카메라 마우스 컨트롤

마우스를 움직이면 카메라가 회전해야 한다.

```gdscript
@export var mouse_sensitivity: float = 0.003  # 마우스 감도

func _input(event):
    if event is InputEventMouseMotion:
        # event.relative: 이번 프레임에서 마우스가 얼마나 움직였는지 (픽셀 단위)
        # relative.x: 좌우 이동 픽셀, relative.y: 상하 이동 픽셀

        # 좌우 회전: Player 전체를 Y축으로 회전
        rotate_y(-event.relative.x * mouse_sensitivity)
        # 음수(-): 마우스를 오른쪽으로 움직이면 오른쪽을 봐야 하므로

        # 상하 회전: CameraPivot만 X축으로 회전
        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        # 음수(-): 마우스를 위로 올리면 위를 봐야 하므로

        # 상하 각도 제한: 너무 위나 아래를 보지 못하게
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.2, 0.4)
        # -1.2 라디안 ≈ -69도 (위 방향 최대)
        # 0.4 라디안 ≈ 23도 (아래 방향 최대)
```

**`event.relative`란:**
마우스가 이번 프레임에서 움직인 픽셀 수다. 절대 위치가 아니다.
마우스를 빠르게 움직이면 큰 값, 천천히 움직이면 작은 값이 나온다.
MOUSE_MODE_CAPTURED 모드에서는 마우스가 화면 중앙에 고정되어 있어도 `relative`는 계속 값이 들어온다.

**`clamp`로 각도 제한하는 이유:**
제한 없으면 카메라가 완전히 뒤집어지거나(위로 360도), 바닥을 보다가 뒤로 가는 등 어색한 상황이 생긴다.

---

### 달리기 (Sprint) 구현

이동 중 Shift를 누르면 속도가 빨라지는 패턴:

```gdscript
@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0

func _physics_process(delta):
    # Shift 누르면 달리기 속도, 아니면 걷기 속도
    var current_speed = run_speed if Input.is_action_pressed("sprint") else walk_speed

    velocity.x = move_direction.x * current_speed
    velocity.z = move_direction.z * current_speed

    move_and_slide()
```

`@export`로 선언하면 Inspector에서 숫자를 바꿔가며 테스트할 수 있다.

---

### 입력 시스템 (InputMap)

하드코딩(`Input.is_key_pressed(KEY_W)`)보다 InputMap이 낫다:

| 방식 | 코드 | 키 변경 방법 |
|------|------|------------|
| 하드코딩 | `Input.is_key_pressed(KEY_W)` | 코드 수정 필요 |
| InputMap | `Input.is_action_pressed("move_forward")` | project.godot만 수정 |

InputMap을 쓰면 나중에 게임패드 지원을 추가할 때 코드를 건드리지 않아도 된다.
`project.godot`에 새 입력 장치를 연결하기만 하면 된다.

```gdscript
# 입력 읽기 (4방향을 한 번에)
var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
# 반환값: Vector2, x는 좌우(-1~1), y는 앞뒤(-1~1)

# 점프
if Input.is_action_just_pressed("jump") and is_on_floor():
    velocity.y = JUMP_VELOCITY
```

**`is_action_pressed` vs `is_action_just_pressed`:**
- `is_action_pressed`: 키를 누르고 있는 동안 매 프레임 true
- `is_action_just_pressed`: 키를 누른 그 프레임만 true (점프에 적합)

**InputMap 등록 방법 (에디터):**
`Project → Project Settings → Input Map` 탭에서 이름을 추가하고 키를 배정한다.

Claude에게 `project.godot`를 직접 수정해달라고 요청할 수도 있다.

---

### 상태 머신 (State Machine) 기초

복잡한 플레이어 동작을 if-else 덩어리로 관리하면 금방 엉킨다.
상태 머신은 "지금 어떤 상태인가"를 명확히 구분해서 관리하는 방법이다.

```
Idle  ──(이동 입력)──▶  Walking
         ◀──(입력 없음)──

Walking  ──(Space)──▶  Jumping
Jumping  ──(바닥 닿음)──▶  Idle

Walking  ──(공격 키)──▶  Attacking
Attacking ──(애니메이션 끝)──▶  Idle
```

```gdscript
enum State { IDLE, WALKING, JUMPING, ATTACKING }
var current_state = State.IDLE

func _physics_process(delta):
    match current_state:
        State.IDLE:
            if input.length() > 0.1:
                current_state = State.WALKING
        State.WALKING:
            _handle_movement(delta)
            if not is_on_floor():
                current_state = State.JUMPING
        State.JUMPING:
            _handle_gravity(delta)
            if is_on_floor():
                current_state = State.IDLE
```

**상태 머신이 필요한 이유:**
공격 중에는 이동을 막고 싶다거나, 점프 중에는 구르기를 못 하게 하고 싶을 때,
상태 머신 없이 if-else로 처리하면 조건이 기하급수적으로 늘어난다.

상태 머신이 있으면 `ATTACKING` 상태에서는 이동 코드 자체를 실행하지 않으면 된다.

---

### 더블 점프 구현 패턴

```gdscript
var jump_count: int = 0
const MAX_JUMPS: int = 2

func _physics_process(delta):
    if is_on_floor():
        jump_count = 0  # 바닥에 닿으면 초기화

    if Input.is_action_just_pressed("jump"):
        if is_on_floor() or jump_count < MAX_JUMPS:
            velocity.y = JUMP_VELOCITY
            jump_count += 1
```

**핵심:** `jump_count`를 별도 변수로 관리한다.
`is_on_floor()`만으로는 공중에 있는지 알 수 있지만, 몇 번 점프했는지는 알 수 없다.

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
3, 5, 8, 15로 각각 테스트해보고 어떤 값이 가장 자연스러운지 파악.

### 실습 9-3: 더블 점프 추가

Claude에게 다음 요청:

> "플레이어 스크립트에 더블 점프를 추가해줘.
> 공중에 있을 때 Space를 한 번 더 누르면 한 번 더 점프할 수 있어.
> 바닥에 닿으면 더블 점프 횟수가 리셋돼야 해."

### 실습 9-4: 상태 머신으로 리팩토링

Claude에게 다음 요청:

> "현재 player.gd의 이동·점프 로직을 상태 머신(enum State)으로 리팩토링해줘.
> 상태는 IDLE, WALKING, JUMPING 세 가지로 나눠줘.
> 각 상태에서 어떤 입력을 처리하는지 주석으로 설명해줘."

---

## 확인 포인트

- [ ] CameraPivot이 왜 별도로 있는지 설명할 수 있다 (상하 회전 분리)
- [ ] SpringArm3D가 벽 통과를 어떻게 막는지 안다
- [ ] 이동 방향이 카메라 기준으로 변환되어야 하는 이유를 안다
- [ ] `cam_basis * Vector3(input.x, 0, input.y)`가 무슨 계산인지 개념적으로 안다
- [ ] `lerp_angle`이 일반 `lerp`와 다른 이유를 안다
- [ ] `is_action_pressed`와 `is_action_just_pressed`의 차이를 안다
- [ ] InputMap을 쓰는 이유를 설명할 수 있다 (하드코딩 대비 장점)
- [ ] 상태 머신이 if-else 덩어리보다 나은 이유를 안다

## 다음 챕터
[Ch10 — 적 AI & 내비게이션](./ch10_enemy_ai.md)
