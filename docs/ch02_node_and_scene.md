# Ch02 — 노드 & 씬 시스템

> Godot의 모든 것은 Node다. 이 말의 의미를 이해하면
> 게임 구조를 읽고 설계하는 능력이 생긴다.

---

## 개념

### Node란?

Godot에서 모든 게임 오브젝트는 **Node**다.
Node는 아래 특성을 가진다:

- 이름이 있다 (`Player`, `Camera3D`, `Ground` 등)
- 부모/자식 관계로 **트리 구조**를 이룬다
- 스크립트(`.gd`)를 붙이면 동작을 추가할 수 있다
- `_ready()`, `_process()` 같은 라이프사이클 함수를 통해 엔진과 소통한다

**비유: Node는 레고 블록**
개별 레고 블록은 그 자체로 아무것도 안 하지만,
블록들을 조합해서 집을 만들 수 있다.
Godot에서도 노드들을 조합해서 게임 오브젝트를 만든다.

---

### Node Tree (노드 트리)

씬 패널에서 보이는 계층 구조. **부모 노드가 움직이면 자식 노드들도 함께 움직인다.**

```
World (Node3D)                ← 씬의 루트 (최상위)
├── DirectionalLight3D        ← 태양 조명
├── Ground (StaticBody3D)     ← 고정된 바닥
│   ├── MeshInstance3D        ← 바닥의 모양 (눈에 보이는 것)
│   └── CollisionShape3D      ← 바닥의 충돌 영역 (물리 처리)
└── Player (CharacterBody3D)  ← 플레이어 캐릭터
    ├── MeshInstance3D        ← 플레이어 모양
    ├── CollisionShape3D      ← 플레이어 충돌 영역
    └── Camera3D              ← 플레이어 시점 카메라
```

**Player가 이동하면 Camera3D도 함께 이동하는 이유:**
Camera3D가 Player의 자식이기 때문. 부모의 위치가 바뀌면 자식도 자동으로 따라간다.

---

### 자주 쓰는 3D Node

#### 기본 노드

| Node | 역할 | 언제 쓰나 |
|------|------|----------|
| `Node3D` | 3D 공간의 기본 컨테이너. 위치/회전/크기만 가짐 | 논리적 그룹화, 카메라 피벗 |
| `MeshInstance3D` | 3D 모양을 화면에 표시 | 눈에 보이는 모든 3D 오브젝트 |
| `Camera3D` | 플레이어 시점. 이게 없으면 화면에 아무것도 안 보임 | 카메라 |

#### 물리 노드 (Physical Body)

| Node | 특성 | 용도 |
|------|------|------|
| `CharacterBody3D` | 코드로 직접 이동 제어. `move_and_slide()` 사용 | 플레이어, NPC, 적 |
| `StaticBody3D` | 고정됨. 물리 엔진이 움직이지 않음 | 바닥, 벽, 고정 장애물 |
| `RigidBody3D` | 물리 엔진이 자동으로 움직임. 중력, 마찰 자동 적용 | 굴러다니는 공, 떨어지는 물체 |
| `AnimatableBody3D` | StaticBody3D인데 애니메이션으로 이동 가능 | 움직이는 플랫폼, 엘리베이터 |

**항상 짝으로 쓰는 것:**
모든 물리 Body에는 **CollisionShape3D**가 반드시 필요하다.
CollisionShape3D 없이는 물리 충돌이 작동하지 않는다.

```
CharacterBody3D            ← Body (물리 적용)
└── CollisionShape3D       ← 충돌 모양 정의
    └── CapsuleShape3D     ← 실제 모양 (캡슐/박스/구 등)
```

#### 감지/트리거 노드

| Node | 역할 |
|------|------|
| `Area3D` | 물체가 들어오거나 나갈 때 Signal을 발생시키는 영역 |
| `CollisionShape3D` | Area3D나 Body에 붙여서 충돌/감지 범위를 정의 |
| `RayCast3D` | 특정 방향으로 선을 쏴서 뭔가 맞는지 확인 |

#### 조명 & 환경

| Node | 역할 |
|------|------|
| `DirectionalLight3D` | 태양처럼 전체에 같은 방향의 조명 |
| `OmniLight3D` | 전구처럼 모든 방향으로 퍼지는 조명 |
| `SpotLight3D` | 손전등처럼 원뿔 형태 조명 |
| `WorldEnvironment` | 하늘, 안개, 전체 분위기 설정 |

#### 내비게이션 (적 AI용)

| Node | 역할 |
|------|------|
| `NavigationRegion3D` | 걸어다닐 수 있는 바닥 영역 정의 |
| `NavigationAgent3D` | A* 알고리즘으로 길 찾아 이동하는 에이전트 |

---

### Scene (씬) 시스템

**씬이란?** 노드들의 묶음을 하나의 `.tscn` 파일로 저장한 것.

```
Player.tscn 파일 안에:
Player (CharacterBody3D)
├── MeshInstance3D
├── CollisionShape3D
└── Camera3D
```

#### 씬 인스턴싱 — 설계도와 실체

**비유: 설계도와 집**
- 설계도 1장(`.tscn` 파일) → 집을 100채 지을 수 있다
- 집 1채를 수정하고 싶으면 설계도를 수정하면 나머지도 자동 반영

```
Enemy.tscn (설계도 1개)
    ↓ 인스턴싱
Level 씬에 배치된 Enemy 10마리  ← 각각 독립된 인스턴스
    (Enemy.tscn 수정 → 10마리 모두 자동 반영)
```

**인스턴싱 실용 예:**
- 적 씬 하나 만들어두면 레벨에 몇 개든 배치 가능
- 코인 씬 하나로 맵 전체에 코인 배치
- 총알 씬을 발사할 때마다 새로 생성

---

### Signal (시그널)

"어떤 일이 일어났을 때" 다른 노드에게 알리는 시스템.
**이벤트 기반 프로그래밍**의 핵심 개념.

**비유: 경보 시스템**
- 금고(적)에 센서(Area3D)를 달아둠
- 누군가 들어오면 경보음이 울림(Signal 발생)
- 경비실(GameManager)이 경보를 듣고 대응

```gdscript
# Signal 발생 (적이 Player를 감지했을 때)
signal player_detected(player)

# Signal을 다른 곳에서 구독
enemy.player_detected.connect(_on_player_detected)

func _on_player_detected(player):
    print("플레이어 발견! 추격 시작")
```

**자주 쓰는 내장 Signal:**
| Signal | 발생 시점 |
|--------|----------|
| `Area3D.body_entered(body)` | 물체가 Area3D 안으로 들어올 때 |
| `Area3D.body_exited(body)` | 물체가 Area3D 밖으로 나갈 때 |
| `Button.pressed` | 버튼을 클릭할 때 |
| `Timer.timeout` | 타이머가 0이 될 때 |
| `AnimationPlayer.animation_finished` | 애니메이션이 끝날 때 |

---

### Node 라이프사이클

모든 Node는 생성부터 삭제까지 정해진 순서로 함수가 호출된다:

```
씬 로드 → _ready() → [_process() 반복] → queue_free() → 삭제
```

| 함수 | 호출 시점 | 주요 용도 |
|------|----------|----------|
| `_ready()` | 씬이 완전히 로드된 직후 (1번만) | 초기화, 노드 참조, Signal 연결 |
| `_process(delta)` | 매 렌더링 프레임마다 | UI 업데이트, 카메라 |
| `_physics_process(delta)` | 물리 프레임마다 (고정 주기) | 이동, 충돌 |
| `_input(event)` | 입력 이벤트 발생 시 | 마우스/키 입력 |

---

### 노드 참조 방법

코드에서 다른 노드에 접근하는 방법들:

```gdscript
# 1. $ 단축 문법 (자식 노드)
$Camera3D
$CameraPivot/SpringArm3D   # 경로 지정

# 2. get_node() (유연한 경로 지정)
get_node("Camera3D")        # 자식
get_node("../Player")       # 부모로 올라가서

# 3. @onready 변수 (권장 방식)
@onready var camera = $Camera3D  # _ready() 시점에 자동 할당

# 4. 그룹으로 찾기
get_tree().get_nodes_in_group("enemy")   # 'enemy' 그룹의 모든 노드

# 5. 씬 전체에서 찾기 (느림, 남용 금지)
get_tree().get_first_node_in_group("player")
```

**`@onready`를 쓰는 이유:**
`$Camera3D`를 변수 선언 시점에 쓰면 `_ready()` 이전이라 노드가 아직 없어서 오류가 난다.
`@onready`는 `_ready()` 직전에 자동으로 할당해주므로 안전하다.

```gdscript
# 나쁜 예 (에러 발생 가능)
var camera = $Camera3D   # 선언 시점에 Camera3D가 아직 없을 수 있음

# 좋은 예
@onready var camera: Camera3D = $Camera3D   # _ready() 직전에 안전하게 할당
```

---

### 씬 분리의 원칙

큰 씬 하나에 모든 걸 넣지 않고, **역할별로 분리**하는 것이 좋다:

```
좋은 구조:
world.tscn         ← 레벨 씬 (바닥, 장애물, 조명)
    ← player.tscn 인스턴스 포함
    ← enemy.tscn 인스턴스 여러 개 포함
    ← coin.tscn 인스턴스 여러 개 포함

나쁜 구조:
world.tscn         ← 모든 것이 다 들어있음 (1000개 노드)
    └── 수정하기 어렵고, 재사용 불가능
```

---

## 실습

### 실습 2-1: 노드 트리 읽기 연습
Godot 에디터에서 `scenes/world.tscn`을 열고 씬 패널의 노드 트리를 본다.
- 루트 노드가 무엇인지 확인
- Player의 자식 노드들을 확인
- Camera3D가 Player의 자식인 이유를 생각해본다

### 실습 2-2: Signal 실험
Claude에게 다음 요청:

> "Godot 4에서 Area3D로 플레이어가 특정 구역에 들어오면
> print('플레이어 진입!')을 출력하는 예제를 만들어줘.
> `res://scenes/trigger_zone.tscn`으로 저장하고
> world.tscn에 하나 배치해줘."

F6으로 실행해서 구역에 들어갈 때 콘솔에 메시지가 뜨는지 확인한다.

### 실습 2-3: 씬 인스턴싱 실험
Claude에게 다음 요청:

> "Godot 4에서 회전하는 코인 씬을 만들어줘.
> `res://scenes/coin.tscn` - 금색 CylinderMesh, Y축으로 회전
> world.tscn에 5개를 다른 위치에 배치해줘."

씬 패널에서 5개의 coin 인스턴스가 보이는지 확인하고,
coin.tscn을 수정해서 색을 바꾸면 5개 모두 바뀌는 것을 확인한다.

---

## 확인 포인트
- [ ] Node와 Scene의 차이를 설명할 수 있다 (최소 단위 vs 묶음)
- [ ] 부모-자식 관계가 왜 중요한지 안다 (부모 이동 시 자식도 이동)
- [ ] CharacterBody3D와 StaticBody3D의 차이를 안다
- [ ] CollisionShape3D가 Body에 항상 필요한 이유를 안다
- [ ] Signal이 어떤 상황에 쓰이는지 예를 들 수 있다
- [ ] `@onready`를 쓰는 이유를 안다
- [ ] 씬 인스턴싱의 장점을 안다 (설계도-실체 개념)

## 다음 챕터
[Ch03 — GDScript 독해력](./ch03_gdscript_reading.md)
