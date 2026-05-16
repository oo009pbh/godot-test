# Ch03 Q&A

---

## Q1. world.tscn 하나만 있는데, 캐릭터 같은 객체는 어떻게 씬마다 연결하나?

맞다. `.tscn`은 씬 단위 파일이다.

Godot에서는 **씬도 노드처럼 재사용**할 수 있다. 예를 들어 주인공을 따로 `player.tscn`으로 만들면, 다른 씬에서 그걸 **인스턴스화(instance)** 해서 불러올 수 있다.

```
scenes/
├── world.tscn       ← 월드 씬
├── player.tscn      ← 플레이어 씬 (따로 분리 가능)
└── enemy.tscn       ← 적 씬
```

연결하는 방법은 두 가지다:

**1) 에디터에서 드래그** — `player.tscn`을 `world.tscn`의 씬 트리에 드래그하면 자동으로 인스턴스 노드가 생성된다.

**2) 코드에서 동적 생성** — 게임 중에 적을 스폰하는 것처럼 런타임에 생성할 때 쓴다.

```gdscript
# 미리 씬 파일을 로드
const EnemyScene = preload("res://scenes/enemy.tscn")

func spawn_enemy():
	var enemy = EnemyScene.instantiate()  # 인스턴스 생성
	add_child(enemy)                       # 씬 트리에 추가
	enemy.position = Vector3(5, 0, 0)
```

**핵심:** 씬 파일(`.tscn`)은 "재사용 가능한 노드 묶음"이다. 다른 씬에서 import처럼 가져다 쓸 수 있다.

---

## Q2. player.gd가 Player 노드에 연결됐다면, 코드는 그 노드를 조작하는 전제인가?

**그렇다.** 스크립트가 노드에 붙으면, 그 스크립트 안의 코드는 **해당 노드 자체**가 된다.

```gdscript
extends CharacterBody3D  # 이 스크립트는 CharacterBody3D 노드다

func _physics_process(delta):
	velocity.y -= 9.8 * delta  # velocity = 이 노드(Player)의 velocity
	move_and_slide()            # 이 노드를 이동시키는 함수
```

- `velocity`, `position`, `rotation` 같은 속성들은 **이 노드의 속성**
- `move_and_slide()`, `is_on_floor()` 같은 함수들은 **이 노드의 메서드**
- 명시적으로 쓰면 `self.velocity`, `self.move_and_slide()` — `self` 생략 가능

`$Camera3D`는 "이 노드의 자식 중 Camera3D를 찾아라"는 뜻이다.
`get_parent()`는 "이 노드의 부모를 가져와라"는 뜻이다.

**요약:** `player.gd` 안에서의 `self` = Player 노드 = CharacterBody3D.

---

## Q3. 라이프사이클이 JS의 mount/render 단계와 비슷한 것 같은데, 이벤트는 어떻게 전파되나?

비유가 정확하다. `_ready()` ≈ `componentDidMount`, `_process()` ≈ `render loop`와 비슷하다.

Godot의 이벤트 전파는 크게 세 가지 방식이 있다:

### 1) Signal (가장 많이 씀)

노드가 "무언가 일어났다"고 **신호를 보내면**, 연결된 함수가 자동 호출된다.

```gdscript
# Area3D (함정 구역)에 플레이어가 들어오면 → 신호 발생
$TrapArea.body_entered.connect(_on_trap_entered)

func _on_trap_entered(body):
	if body.name == "Player":
		body.take_damage(10)
```

Signal은 이벤트 리스너 패턴이다. DOM의 `addEventListener`와 동일한 개념.

### 2) 직접 참조 (부모 → 자식)

```gdscript
# 부모 씬에서 자식 노드 직접 접근
$Player.speed = 10.0
$Enemy.die()
```

### 3) Group (브로드캐스트)

여러 노드에 동시에 신호를 보낼 때 — 예) 모든 적에게 "경계" 상태 전달.

```gdscript
# 모든 "enemies" 그룹 노드의 alert() 호출
get_tree().call_group("enemies", "alert")
```

### 이벤트 전파 방향 정리

| 방향 | 방법 |
|------|------|
| 부모 → 자식 | `$자식노드.함수()` 직접 호출 |
| 자식 → 부모 | Signal 발행 → 부모가 구독 |
| 노드 → 다수 | Group + `call_group()` |
| 씬 전체 | `get_tree()`로 씬 매니저 접근 |

**핵심:** Godot는 Signal을 중심으로 느슨하게 연결한다. 자식이 부모를 직접 참조하면 결합도가 높아지므로 Signal 권장.

---

## Q4. 보통 객체지향적으로 Godot 코딩을 하나?

**반반이다.** Godot는 OOP지만, 순수 OOP보다는 **컴포지션(Composition) 중심**으로 설계하는 걸 권장한다.

### OOP적인 부분

```gdscript
# 상속 — extends로 클래스 확장
class_name Enemy extends CharacterBody3D

var health: int = 100

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()  # 노드 삭제
```

`class_name`을 선언하면 다른 스크립트에서 타입으로 쓸 수 있다.

### 컴포지션 중심인 부분

Godot에서는 "기능을 상속으로 추가"하기보다 **씬 트리에 노드를 붙이는 방식**을 선호한다.

```
Player (CharacterBody3D)
├── HealthComponent  ← 체력 관리 노드
├── AttackComponent  ← 공격 로직 노드
└── AnimationPlayer  ← 애니메이션 노드
```

각 노드가 독립적인 책임을 가지고, Signal로 서로 통신한다.

### 요약

| 상황 | 접근법 |
|------|--------|
| 기본 타입 재사용 (캐릭터, 무기 등) | `class_name` + `extends`로 상속 |
| 기능 조합 (체력, 공격, AI 등) | 씬 트리에 컴포넌트 노드 추가 |
| 이벤트 연결 | Signal (느슨한 결합) |

Godot의 철학: **"코드 상속보다 씬 컴포지션"**.

---

---

## Q5. Godot에서 함수형 프로그래밍을 쓸 수 있나? JS 이터레이터 같은 개념으로

**쓸 수 있다.** Godot 4부터 Array에 `map`, `filter`, `reduce` 등이 추가됐다.

### 람다 (Callable)

```gdscript
var double = func(x): return x * 2
print(double.call(5))  # 10
```

### map / filter / reduce

```gdscript
var numbers = [1, 2, 3, 4, 5]

var doubled = numbers.map(func(x): return x * 2)
# [2, 4, 6, 8, 10]

var evens = numbers.filter(func(x): return x % 2 == 0)
# [2, 4]

var sum = numbers.reduce(func(acc, x): return acc + x, 0)
# 15
```

### any / all

```gdscript
var has_big = numbers.any(func(x): return x > 4)   # true
var all_positive = numbers.all(func(x): return x > 0)  # true
```

### JS 이터레이터(generator)와의 차이

JS의 `function*` / `yield` 같은 **제너레이터는 없다.** 지연 평가(lazy evaluation)가 필요하면 직접 인덱스를 관리하거나 별도 클래스를 만들어야 한다.

**요약:** `map/filter/reduce` + 람다는 된다. JS generator 스타일 이터레이터 프로토콜은 없다.

---

## 다음 챕터
[Ch04 — Claude에게 잘 지시하는 법](./ch04_directing_ai.md)
