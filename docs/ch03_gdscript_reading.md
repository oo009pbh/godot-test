# Ch03 — GDScript 독해력

> 코드를 직접 짜는 게 목표가 아니라, **Claude가 만든 코드를 읽고 이해하는 것**이 목표다.
> 코드를 읽을 수 있어야 "이 부분을 바꿔줘"라고 정확하게 요청할 수 있다.

---

## 개념

### GDScript 기본 구조

```gdscript
extends CharacterBody3D   # 이 스크립트가 붙은 Node의 타입

# 변수 선언
var speed: float = 5.0
var health: int = 100
var is_dead: bool = false

# 라이프사이클 함수들
func _ready():
    # 씬이 로드될 때 1번 실행
    print("Player spawned!")

func _process(delta: float):
    # 매 프레임마다 실행 (delta = 이전 프레임과의 시간 간격)
    pass

func _physics_process(delta: float):
    # 물리 연산 프레임마다 실행 (CharacterBody3D 이동에 사용)
    pass
```

---

### 라이프사이클 함수 완전 정리

Godot는 노드의 상태 변화에 따라 특정 함수를 자동으로 호출한다.
이 함수들을 **라이프사이클 함수** (또는 가상 함수, virtual function)라고 부른다.

#### 실행 순서 타임라인

```
씬 로드
  │
  ▼
_init()          ← 객체 생성 직후 (씬 트리에 들어오기 전)
  │
  ▼
_enter_tree()    ← 씬 트리에 추가되는 순간
  │
  ▼
_ready()         ← 자식 노드까지 모두 준비 완료
  │
  ▼  [매 프레임 반복]
  ├─ _process(delta)          ← 렌더링 프레임마다 (UI, 애니메이션 등)
  ├─ _physics_process(delta)  ← 물리 프레임마다 (이동, 충돌 등)
  └─ _input(event)            ← 입력 이벤트 발생 시
  │
  ▼
_exit_tree()     ← 씬 트리에서 제거되는 순간 (씬 전환, queue_free 등)
```

#### 각 함수 상세

**`_init()`**
```gdscript
func _init():
    # 객체가 메모리에 생성되는 순간 실행
    # 씬 트리에 아직 없으므로 $Camera3D 같은 노드 참조 불가
    # 거의 사용 안 함 — 대부분 _ready()로 충분
    pass
```

**`_enter_tree()`**
```gdscript
func _enter_tree():
    # 이 노드가 씬 트리에 추가되는 순간
    # 자식 노드들은 아직 준비 안 됐을 수 있음
    # 사용 예: 부모 노드에게 자신을 등록할 때
    pass
```

**`_ready()`**
```gdscript
func _ready():
    # 자식 노드까지 전부 준비된 후 딱 1번만 실행
    # 초기화 로직은 여기에 — 가장 많이 쓰는 함수
    $Camera3D.fov = 75          # 자식 노드 접근 안전
    print("준비 완료!")
```

**`_process(delta)`**
```gdscript
func _process(delta: float):
    # 매 렌더링 프레임마다 실행 (보통 60fps = 초당 60번)
    # delta = 이전 프레임과의 시간 간격 (초 단위, 약 0.016)
    # 사용 예: UI 업데이트, 애니메이션, 카메라 회전

    # delta를 곱하면 프레임레이트와 무관하게 일정한 속도
    rotation.y += 1.0 * delta   # 초당 1 라디안 회전
```

**`_physics_process(delta)`**
```gdscript
func _physics_process(delta: float):
    # 물리 엔진 프레임마다 실행 (기본 60Hz, 고정 주기)
    # CharacterBody3D, RigidBody3D 이동은 반드시 여기서
    # _process와 달리 주기가 고정 → 물리 연산이 일관됨

    velocity.y -= 9.8 * delta   # 중력 적용
    move_and_slide()            # 충돌 감지하며 이동
```

**`_input(event)`**
```gdscript
func _input(event: InputEvent):
    # 키보드, 마우스, 터치 등 입력 이벤트 발생 시 호출
    # Input.is_action_pressed()와 차이:
    #   - _input(): 이벤트 기반 (발생 시 1번)
    #   - is_action_pressed(): 폴링 방식 (매 프레임 확인)

    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * 0.002)  # 마우스로 좌우 회전
```

**`_exit_tree()`**
```gdscript
func _exit_tree():
    # 이 노드가 씬 트리에서 제거될 때 실행
    # 사용 예: 연결한 시그널 해제, 리소스 정리
    print("Player removed")
```

#### `_process` vs `_physics_process` 선택 기준

| 상황 | 사용 함수 |
|------|-----------|
| 플레이어 이동, 충돌 감지 | `_physics_process` |
| UI 업데이트, HUD 숫자 표시 | `_process` |
| 카메라 흔들림, 시각 효과 | `_process` |
| 마우스 회전 (부드러운 카메라) | `_process` |
| 발사체, 물리 오브젝트 | `_physics_process` |

#### delta를 곱하는 이유

```gdscript
# 나쁜 예 — 프레임레이트에 따라 속도가 달라짐
position.x += 0.1          # 60fps: 초당 6, 30fps: 초당 3 (불일치!)

# 좋은 예 — 프레임레이트와 무관하게 일정
position.x += 6.0 * delta  # 60fps든 30fps든 초당 6 (일관됨)
```

### 읽는 법: 핵심 패턴 5가지

**1. `$노드이름` — 자식 노드 참조**
```gdscript
$Camera3D          # 자식 노드 Camera3D를 가져옴
$MeshInstance3D    # 자식 노드 MeshInstance3D를 가져옴
```

**2. `get_node("경로")` — 노드 찾기**
```gdscript
get_node("Camera3D")            # 자식에서 찾기
get_node("../Enemy")            # 부모로 올라가서 찾기
get_node("/root/GameManager")   # 절대 경로로 찾기
```

**3. Signal 연결**
```gdscript
# 코드에서 Signal 연결하기
$Area3D.body_entered.connect(_on_area_entered)

func _on_area_entered(body):
    print("누군가 들어왔다: ", body.name)
```

**4. `Input` — 입력 처리**
```gdscript
if Input.is_action_pressed("ui_right"):   # 오른쪽 방향키 누르는 동안
    velocity.x += speed

if Input.is_action_just_pressed("jump"):  # 한 번만 감지
    jump()
```

**5. `@export` — Inspector에서 값 편집 가능**
```gdscript
@export var speed: float = 5.0    # Inspector에서 숫자 조절 가능
@export var enemy_scene: PackedScene  # Inspector에서 씬 파일 드래그 가능
```

### 에러 메시지 읽는 법

```
E 0:00:01:0342   player.gd:15 @ _ready():
  Node not found: "Camera" in path "."
  ↑파일명  ↑줄번호  ↑함수명
```

- **파일명:줄번호** → 에러가 발생한 위치
- **Node not found** → 해당 이름의 자식 노드가 없음
- **Null instance** → 변수에 아무것도 없는데 사용하려 했음
- **Invalid get index** → 없는 속성에 접근하려 했음

---

## 실습

### 실습 3-1: 코드 읽기 연습
Claude에게 "기본 플레이어 이동 스크립트를 만들어줘" 요청 후,
생성된 코드를 보며 다음을 찾아본다:
- `extends` 뒤에 어떤 타입인가?
- `_process`와 `_physics_process` 중 어느 것을 쓰는가?
- `Input.is_action_pressed`로 어떤 키를 감지하는가?

### 실습 3-2: @export로 값 조절
Claude가 `@export var speed: float = 5.0`이 있는 스크립트를 만들어주면:
1. Godot 에디터에서 해당 Node를 클릭
2. Inspector에서 `Speed` 값을 10.0으로 바꾸기
3. F6 실행 → 더 빠르게 움직이는지 확인

---

## 확인 포인트
- [ ] `$Camera3D`가 무엇을 의미하는지 안다
- [ ] `_ready()`와 `_process()`의 차이를 안다
- [ ] 에러 메시지에서 파일명과 줄번호를 찾을 수 있다
- [ ] `@export` 변수를 Inspector에서 조절할 수 있다

## 다음 챕터
[Ch04 — Claude에게 잘 지시하는 법](./ch04_directing_ai.md)
