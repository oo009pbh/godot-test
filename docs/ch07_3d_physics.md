# Ch07 — 3D 물리 & 충돌

---

## 개념

### Godot의 물리 엔진이 하는 일

게임에서 "물리"란 두 가지를 의미한다:

1. **중력** — 아무것도 안 하면 오브젝트가 아래로 떨어진다
2. **충돌** — 두 오브젝트가 서로 겹치지 않도록 막아준다

Godot는 이 두 가지를 자동으로 처리해준다.
단, **물리를 처리받으려면 적합한 Body 노드를 써야 한다.**
일반 `Node3D`는 물리 엔진이 아예 모른다.

---

### 물리 Body 종류 비교

Godot에는 4가지 물리 Body가 있다.

| Body | 움직임 방식 | 충돌 처리 | 주 용도 |
|------|------------|----------|---------|
| `StaticBody3D` | 코드/물리 모두 불가 | 충돌을 막아냄 | 바닥, 벽, 움직이지 않는 장애물 |
| `CharacterBody3D` | 코드로 직접 제어 | 충돌을 막아냄 | 플레이어, 적 캐릭터 |
| `RigidBody3D` | 물리 엔진이 자동 제어 | 충돌을 막아냄 | 상자, 공, 드럼통 |
| `Area3D` | 코드로 움직일 수 있음 | 충돌 안 막음, 감지만 함 | 아이템 획득 범위, 함정 구역 |

**현실 세계 비유:**

- `StaticBody3D` = **건물 바닥**. 절대 안 움직이고, 모든 것을 막아선다.
- `CharacterBody3D` = **게임 캐릭터**. 내가 키보드로 직접 조종한다.
- `RigidBody3D` = **당구공**. 처음에 힘을 주면, 이후는 물리 법칙이 알아서 움직인다.
- `Area3D` = **자동문 센서**. 사람이 들어오면 감지하지만, 사람을 막거나 밀지 않는다.

---

### CollisionShape3D — 충돌 범위를 정의하는 자식 노드

**Body 노드만 있으면 충돌이 동작하지 않는다.**
반드시 `CollisionShape3D` 자식을 붙여야 한다.

왜냐하면 Godot의 물리 엔진은 **눈에 보이는 모양(Mesh)을 보지 않는다.**
오직 `CollisionShape3D`가 정의한 눈에 보이지 않는 충돌 범위만 본다.

```
[잘못된 구조 — 충돌 안 됨]
StaticBody3D
└── MeshInstance3D  ← 보이기만 하고 충돌 없음

[올바른 구조 — 충돌 됨]
StaticBody3D
├── MeshInstance3D        ← 눈에 보이는 모양
└── CollisionShape3D      ← 물리 엔진이 보는 충돌 범위
    └── shape: BoxShape3D
```

**현실 비유:**
MeshInstance3D는 사람 눈에 보이는 그림이고,
CollisionShape3D는 실제로 충돌하는 투명한 껍데기다.
그림과 껍데기는 별개다.

---

### Shape 종류 선택 기준

`CollisionShape3D`에 붙이는 Shape를 어떻게 고르는지:

| Shape | 모양 | 언제 쓰는가 |
|-------|------|------------|
| `BoxShape3D` | 직육면체 | 상자, 건물 벽, 바닥 |
| `CapsuleShape3D` | 캡슐 (원통+반구) | 사람, 적 캐릭터 |
| `SphereShape3D` | 구 | 공, 파티클 |
| `ConcavePolygonShape3D` | 메시 그대로 | 복잡한 지형 (성능 주의) |

**CapsuleShape3D를 캐릭터에 쓰는 이유:**
사람 형태를 정확히 따라가기보다, 캡슐로 단순화하면 모서리가 없어서
계단이나 경사면을 자연스럽게 올라갈 수 있다.

**ConcavePolygonShape3D 경고:**
메시를 그대로 따라가므로 정확하지만 매우 느리다.
움직이는 오브젝트에는 절대 사용하지 말 것.

---

### CharacterBody3D 이동 패턴

`CharacterBody3D`는 스스로 움직이지 않는다.
코드에서 `velocity`에 값을 넣고 `move_and_slide()`를 호출해야 한다.

```gdscript
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta):
    # 1. 중력: 공중에 있으면 아래로 가속
    if not is_on_floor():
        velocity.y -= 9.8 * delta
        # velocity.y가 점점 음수로 커짐 = 낙하 속도 증가

    # 2. 점프: 바닥에 있을 때 스페이스 누르면 위로 속도 부여
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # 3. 이동: 방향키 입력 → velocity.x, velocity.z 설정
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity.x = input_dir.x * SPEED
    velocity.z = input_dir.y * SPEED

    # 4. 실제 이동 + 충돌 처리 (이 한 줄이 전부 처리함)
    move_and_slide()
```

---

### `move_and_slide()`가 하는 일

이 함수가 없으면 `velocity`를 아무리 설정해도 아무것도 안 움직인다.
이 함수 하나가 세 가지를 한다:

1. **이동**: `velocity * delta`만큼 캐릭터를 실제로 움직인다
2. **충돌 감지**: 이동 경로에 다른 오브젝트가 있는지 확인한다
3. **슬라이드**: 막히면 멈추는 게 아니라, 충돌면을 따라 미끄러진다
   - 벽에 비스듬히 달리면 멈추지 않고 벽을 따라 이동하는 이유

**`is_on_floor()`가 가능한 이유:**
`move_and_slide()`를 호출하면 Godot가 "이 캐릭터가 바닥에 닿아있나?"를 자동으로 계산한다.
그 결과가 `is_on_floor()`에 저장된다.
그래서 `move_and_slide()` 전에 `is_on_floor()`를 부르면 정확하지 않을 수 있다.

---

### Layer & Mask — 충돌 그룹 설정

모든 오브젝트를 서로 충돌하게 하면 불필요한 연산이 많아진다.
예: 총알끼리 서로 충돌할 필요가 없고, 플레이어의 총알이 아군을 맞히면 안 된다.

**Layer** = "나는 몇 번 그룹이다"
**Mask** = "나는 몇 번 그룹과 충돌한다"

```
예시: 레이어를 이렇게 설계한다고 가정

Layer 1: World (바닥, 벽)
Layer 2: Player
Layer 3: Enemy
Layer 4: Projectile (총알)

총알의 설정:
  Collision Layer: 4  (나는 4번이다)
  Collision Mask:  1, 3  (1번·3번과만 충돌 = 바닥, 적에만 맞음)
  → 다른 총알(4번)이나 플레이어(2번)와는 통과됨
```

**라디오 채널 비유:**
Layer는 "내가 방송하는 채널", Mask는 "내가 듣는 채널"이다.
총알이 Layer 4에 있고 Mask에 3만 있으면, 3번 채널(적)의 방송만 수신한다.
총알끼리는 서로 채널이 달라서 무시한다.

Inspector에서 `Collision` 섹션의 Layer/Mask를 클릭해서 설정한다.
숫자가 곧 체크박스 번호다.

---

### Area3D — 충돌 없이 감지만 하는 구역

`Area3D`는 다른 Body와 **겹칠 수 있다**. 막지 않는다.
대신 오브젝트가 영역에 들어오거나 나갈 때 **신호(Signal)를 발생**시킨다.

```
Area3D가 발생시키는 주요 신호:
- body_entered: Body가 이 구역에 들어왔을 때
- body_exited: Body가 이 구역에서 나갔을 때
- area_entered: 다른 Area3D가 들어왔을 때
```

```gdscript
extends Area3D

func _ready():
    # 신호를 함수에 연결 (체크인 이벤트 등록)
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    # body = 구역에 들어온 오브젝트
    if body.is_in_group("player"):
        print("아이템 획득!")
        queue_free()  # 이 노드를 씬에서 제거 (아이템 사라짐)
```

**자동문 비유:**
Area3D = 자동문 앞의 적외선 센서.
사람이 센서 범위에 들어오면 감지하지만, 사람을 막거나 밀지 않는다.
감지됐을 때 문을 여는 행동(신호에 연결한 함수)은 따로 구현한다.

**`queue_free()` 설명:**
`queue_free()`는 "이 노드를 다음 프레임에 삭제해줘"라는 요청이다.
`free()`와 달리 현재 프레임의 처리가 끝난 뒤 안전하게 삭제한다.

---

### `_physics_process` vs `_process` — 언제 무엇을 쓰나

| 함수 | 호출 주기 | 사용 |
|------|----------|------|
| `_process(delta)` | 매 화면 갱신마다 (프레임율에 따라 변동) | UI, 애니메이션, 비물리 이동 |
| `_physics_process(delta)` | 물리 엔진 틱마다 (고정: 기본 60fps) | 물리 이동, `move_and_slide()`, 충돌 판정 |

**CharacterBody3D 이동은 반드시 `_physics_process` 안에서 해야 한다.**
`_process`에서 `move_and_slide()`를 부르면 프레임율에 따라 이동 속도가 달라진다.

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

- [ ] `StaticBody3D`, `CharacterBody3D`, `RigidBody3D`, `Area3D`의 차이를 설명할 수 있다
- [ ] `CollisionShape3D` 없이는 충돌이 동작하지 않는 이유를 안다
- [ ] `move_and_slide()`가 이동 + 충돌 처리 + 슬라이드를 한 번에 한다는 걸 안다
- [ ] `is_on_floor()`가 `move_and_slide()` 이후에 의미 있는 이유를 안다
- [ ] Layer는 "내 그룹", Mask는 "반응할 그룹"이라는 걸 안다
- [ ] `Area3D`는 충돌 없이 감지만 하고, 신호로 반응한다는 걸 안다

## 다음 챕터
[Ch08 — 3D 애셋 가져오기](./ch08_3d_assets.md)
