# Ch18 — 게임 아키텍처 & 리팩토링

> 코드가 늘어날수록 "왜 이걸 고치면 저기가 터지지?"라는 상황이 생긴다.
> 아키텍처는 그 고통을 줄이는 설계 원칙이다.
> 우리 프로젝트 코드를 직접 리팩토링하면서 패턴을 익힌다.

---

## 개념

### 아키텍처가 없으면 생기는 일

게임을 만들다 보면 자연스럽게 이런 코드가 생긴다:

```gdscript
# player.gd — 어느 날의 현실
func take_damage(amount: int) -> void:
    GameManager.health -= amount           # GameManager 내부를 직접 건드림
    GameManager.score -= 5                 # 데미지 받으면 점수도 깎기로 했음
    HUD.health_bar.value = GameManager.health  # HUD도 직접 참조
    AudioManager.play("hurt")
    if GameManager.health <= 0:
        get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")
```

`player.gd` 하나가 `GameManager`, `HUD`, `AudioManager`, `SceneTree`를 전부 알고 있다.
이 상태에서 HUD 구조를 바꾸면 player.gd도 고쳐야 하고,
GameManager 변수명을 바꾸면 player.gd, enemy.gd, coin.gd 전부 고쳐야 한다.

**결합도(Coupling)가 높다** — 이게 유지보수를 어렵게 하는 핵심 원인이다.

---

### 멀티 패러다임 한눈에 보기

게임 개발에서 주로 쓰는 세 가지 관점:

| 패러다임 | 핵심 질문 | Godot에서의 형태 |
|---------|----------|----------------|
| **객체지향(OOP)** | "누가 이 책임을 진다?" | Node 클래스, 상속, `class_name` |
| **컴포넌트** | "어떤 능력을 조합할까?" | 자식 Node로 기능 분리 |
| **이벤트/Signal** | "무슨 일이 일어났음을 어떻게 전달하나?" | Signal + 느슨한 연결 |
| **함수형(FP)** | "이 데이터를 어떻게 변환하나?" | 순수 함수, 사이드 이펙트 없는 유틸 |
| **상태 머신** | "지금 어떤 상태고, 어떤 전환이 가능한가?" | enum + match 또는 State 클래스 |

하나만 선택하는 게 아니다. **상황마다 알맞은 패턴을 고르는 것**이 목표다.

---

## 패턴 1 — Signal 기반 이벤트 설계 (Observer 패턴)

### 문제: 직접 참조

```gdscript
# coin.gd — 나쁜 예
func _on_area_entered(body: Node3D) -> void:
    if body.is_in_group("player"):
        GameManager.score += 10        # GameManager에 직접 접근
        GameManager.coin_count += 1
        HUD.update_coins()             # HUD에 직접 접근
        queue_free()
```

`coin.gd`가 GameManager와 HUD를 **둘 다 알아야** 한다.

### 해결: Signal 발신, 연결은 외부에서

```gdscript
# coin.gd — 좋은 예
signal collected  # "나 수집됐음"만 알린다

func _on_area_entered(body: Node3D) -> void:
    if body.is_in_group("player"):
        collected.emit()
        queue_free()
```

```gdscript
# level1.gd — 연결 담당
func _ready() -> void:
    for coin in get_tree().get_nodes_in_group("coin"):
        coin.collected.connect(GameManager.collect_coin)
        coin.collected.connect(HUD.update_coins)
```

이제 `coin.gd`는 HUD도 GameManager도 모른다.
HUD 구조가 바뀌어도 coin.gd는 건드리지 않아도 된다.

**원칙: 이벤트를 발신하는 쪽은 누가 듣는지 알 필요 없다.**

---

## 패턴 2 — 컴포넌트 분리 (Composition over Inheritance)

### 문제: 뚱뚱해지는 player.gd

Player에 체력, 공격, 인벤토리, 스킬이 추가될수록
`player.gd`가 1000줄이 넘어간다.
Enemy도 체력 시스템이 필요한데 Player와 코드를 복붙하게 된다.

### 해결: 기능을 별도 Node로 분리

```
Player (CharacterBody3D) — player.gd: 이동만
├── HealthComponent (Node) — health_component.gd: 체력/데미지/사망
├── HitboxComponent (Area3D) — hitbox.gd: 피격 감지
├── CameraPivot (Node3D)
│   └── SpringArm3D
│       └── Camera3D
└── ...
```

```gdscript
# health_component.gd — 체력 기능만 담당
class_name HealthComponent
extends Node

signal health_changed(new_value: int, max_value: int)
signal died

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health, max_health)
    if current_health == 0:
        died.emit()

func heal(amount: int) -> void:
    current_health = min(max_health, current_health + amount)
    health_changed.emit(current_health, max_health)
```

이제 Player도 Enemy도 HealthComponent를 자식으로 붙이면 똑같은 체력 시스템을 공유한다.

```gdscript
# player.gd — 이동만 신경 쓴다
@onready var health: HealthComponent = $HealthComponent

func _ready() -> void:
    health.died.connect(_on_died)

func _on_died() -> void:
    GameManager.game_over.emit()
```

**원칙: 상속(is-a)보다 컴포지션(has-a)으로 기능을 조합한다.**

---

## 패턴 3 — 상태 머신 (State Machine)

### 문제: if/else 폭발

Player 이동에 달리기, 구르기, 수영, 등반을 추가할수록 조건문이 폭발한다:

```gdscript
# 나쁜 예: 조건이 서로 얽힘
func _physics_process(delta: float) -> void:
    if is_swimming and not is_climbing:
        # 수영 로직
    elif is_climbing and not is_jumping:
        # 등반 로직
    elif is_rolling:
        # 구르기 로직 (수영 중엔 불가)
    else:
        # 기본 이동
```

### 해결: 상태를 명시적으로 분리

```gdscript
# player.gd — 상태 머신으로 정리
enum State { IDLE, WALK, RUN, JUMP, FALL, ROLL }

var state: State = State.IDLE

func _physics_process(delta: float) -> void:
    match state:
        State.IDLE:  _process_idle(delta)
        State.WALK:  _process_walk(delta)
        State.RUN:   _process_run(delta)
        State.JUMP:  _process_jump(delta)
        State.FALL:  _process_fall(delta)
        State.ROLL:  _process_roll(delta)

func _process_idle(delta: float) -> void:
    if Input.get_vector("move_left", "move_right", "move_forward", "move_backward").length() > 0.1:
        _change_state(State.WALK)
    elif Input.is_action_just_pressed("jump") and is_on_floor():
        _change_state(State.JUMP)

func _change_state(new_state: State) -> void:
    state = new_state
    # 전환 시 초기화 (애니메이션, 쿨다운 등)
```

각 상태가 독립적으로 읽히고, 새 상태를 추가해도 기존 상태를 건드리지 않는다.

**원칙: 서로 다른 상태의 로직은 서로를 건드리지 않아야 한다.**

---

## 패턴 4 — 함수형 스타일 유틸리티

### 순수 함수 (Pure Function)

입력이 같으면 출력이 항상 같고, 외부 상태를 변경하지 않는 함수.

```gdscript
# utils/math_utils.gd — 순수 함수 모음
class_name MathUtils

# 전역 상태 없음, 사이드 이펙트 없음
static func lerp_angle_deg(from: float, to: float, weight: float) -> float:
    return fmod(from + weight * (fmod(to - from + 540.0, 360.0) - 180.0), 360.0)

static func map_range(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
    return out_min + (value - in_min) / (in_max - in_min) * (out_max - out_min)

static func chance(probability: float) -> bool:
    return randf() < probability
```

이런 함수는 테스트하기 쉽고, 어디서든 사용할 수 있다:

```gdscript
# 사용 예
var screen_alpha := MathUtils.map_range(health, 0.0, 100.0, 0.0, 1.0)
var did_crit := MathUtils.chance(0.15)  # 15% 확률
```

### 데이터 변환 체인

```gdscript
# 나쁜 예: 변수 변이(mutation)가 여기저기 퍼짐
var enemies := get_tree().get_nodes_in_group("enemy")
var result = []
for e in enemies:
    if e.is_alive:
        result.append(e.position)
result.sort_custom(func(a, b): return a.distance_to(player.position) < b.distance_to(player.position))

# 좋은 예: 변환 의도가 명확
var nearest_enemies := (get_tree().get_nodes_in_group("enemy")
    .filter(func(e): return e.is_alive)
    .map(func(e): return e.position)
    .sorted_custom(func(a, b): return a.distance_to(player.position) < b.distance_to(player.position)))
```

**원칙: 데이터를 변환하는 로직과 상태를 바꾸는 로직을 분리한다.**

---

## 패턴 5 — 의존성 역전 (@export 주입)

### 문제: 경로 하드코딩

```gdscript
# 나쁜 예
@onready var camera: Camera3D = $"../CameraPivot/SpringArm3D/Camera3D"
```

씬 구조가 바뀌면 이 경로도 바꿔야 한다.

### 해결: @export로 외부에서 주입

```gdscript
# 좋은 예
@export var camera: Camera3D  # 에디터 Inspector에서 드래그로 연결
```

스크립트는 "Camera3D가 필요하다"고만 선언하고, **어디에 있는지는 모른다.**
씬 구조가 바뀌어도 스크립트를 고칠 필요 없이 Inspector에서 다시 연결만 하면 된다.

**원칙: 구체적인 경로나 타입보다 인터페이스(타입 힌트)에 의존한다.**

---

## 리팩토링 판단 기준

코드를 고쳐야 할 타이밍:

| 증상 | 원인 | 해결 패턴 |
|------|------|----------|
| 한 파일이 500줄 넘어감 | 책임이 너무 많음 | 컴포넌트 분리 |
| A 수정했더니 B가 터짐 | 결합도 높음 | Signal, @export 주입 |
| 비슷한 코드가 3곳 이상 | 중복 | 유틸 클래스, 공통 컴포넌트 |
| if/else가 5단계 이상 | 상태 뒤섞임 | 상태 머신 |
| 전역 변수에 직접 접근 | 캡슐화 없음 | 메서드를 통해 접근 |

---

## 우리 프로젝트 아키텍처 지도

```
[GameManager] ←──── Autoload, 전역 상태 보관
    │ Signal
    ▼
[HUD] ─────────── GameManager Signal 구독, 화면 표시만 담당

[Player]
 ├── [HealthComponent] ─── died Signal → GameManager
 ├── [HitboxComponent] ─── body_entered → HealthComponent
 └── 이동 로직만 player.gd에 남김

[Enemy]
 ├── [HealthComponent] ─── 동일한 컴포넌트 재사용
 └── 상태 머신(IDLE/CHASE/ATTACK)

[Coin] ─── collected Signal만 emit, 연결은 level1.gd에서
```

---

## 실습

### 실습 18-1: HealthComponent 분리

Claude에게 요청:

> "우리 프로젝트의 체력 시스템을 HealthComponent로 분리해줘.
>
> 1. `scripts/health_component.gd` 신규 생성
>    - class_name HealthComponent
>    - @export var max_health: int = 100
>    - signal health_changed(current: int, max_val: int)
>    - signal died
>    - take_damage(amount: int), heal(amount: int) 함수
>
> 2. `scenes/player.tscn`에 HealthComponent 자식 노드 추가
>
> 3. `scripts/player.gd` 수정
>    - 직접 GameManager.take_damage()를 부르던 코드를 $HealthComponent.take_damage()로 교체
>    - _ready()에서 $HealthComponent.died.connect(_on_died)
>    - _on_died(): GameManager.game_over.emit()
>
> 4. `scenes/enemy.tscn`에도 같은 HealthComponent 추가
>    - enemy.gd에서 체력 관련 코드 HealthComponent로 위임"

### 실습 18-2: Player 상태 머신 명시화

Claude에게 요청:

> "scripts/player.gd의 이동 로직을 상태 머신으로 리팩토링해줘.
>
> enum State { IDLE, WALK, JUMP, FALL }
>
> - _physics_process에서 match state로 각 상태 함수 호출
> - _change_state(new_state) 함수로 상태 전환
> - 각 상태 함수: _process_idle, _process_walk, _process_jump, _process_fall
> - 기존 기능(WASD 이동, 마우스 카메라, 스페이스 점프)은 그대로 유지
> - SpringArm3D 착지 버그 수정(add_excluded_object)도 유지"

### 실습 18-3: 아키텍처 Q&A

Claude에게 질문:

> "우리 게임에서 새로운 '방패' 아이템을 추가한다면 어디에 무엇을 만들어야 할까?
> 방패는 착용하면 데미지를 50% 줄이고, 아이템 슬롯에 표시된다.
> Ch18의 패턴을 참고해서 설계해줘."

---

## 확인 포인트

- [ ] Signal을 쓰면 발신자와 수신자가 서로를 몰라도 된다는 걸 안다
- [ ] 컴포넌트 분리로 Player와 Enemy가 같은 HealthComponent를 공유할 수 있다는 걸 안다
- [ ] 상태 머신이 복잡한 if/else를 정리하는 방법임을 안다
- [ ] 순수 함수는 테스트하기 쉽고 재사용하기 좋다는 걸 안다
- [ ] @export 주입으로 씬 구조 변경에 스크립트가 영향받지 않도록 할 수 있다

## 다음 챕터

이 챕터까지 완성했다면, Claude와 함께 **자신만의 게임 아이디어**를 설계해보자.
[Ch17 — 미니 프로젝트](./ch17_mini_project.md)가 참고 구조를 제공한다.
