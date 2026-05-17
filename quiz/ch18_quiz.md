# Ch18 퀴즈 — 게임 아키텍처 & 리팩토링

---

## 문제

**Q1.** Signal/Observer 패턴에서 코인이 수집될 때 아래 "나쁜 예" 코드의 문제점은?

```gdscript
# coin.gd — 나쁜 예
func _on_collected(body):
    get_tree().get_first_node_in_group("hud").update_coin()
    get_tree().get_first_node_in_group("game_manager").add_score(10)
    get_tree().get_first_node_in_group("audio").play_sfx("coin")
```

---

**Q2.** 컴포넌트 분리 패턴에서 `HealthComponent`를 별도 노드로 만드는 장점을 2가지 설명하라.

---

**Q3.** 다음 두 코드 중 상태 머신 방식의 장점을 설명하라.

```gdscript
# 방식 A: if-else
func _physics_process(delta):
    if is_on_floor() and not is_attacking and not is_dead:
        _move(delta)
    if velocity.y < 0 and not is_on_floor() and not is_dead:
        _fall(delta)

# 방식 B: 상태 머신
func _physics_process(delta):
    match state:
        State.WALK: _move(delta)
        State.FALL: _fall(delta)
        State.ATTACK: pass
```

---

**Q4.** 다음 유틸리티 함수를 읽고, 이것이 `static func`인 이유는?

```gdscript
class_name MathUtils

static func map_range(value: float, in_min: float, in_max: float,
                      out_min: float, out_max: float) -> float:
    return (value - in_min) / (in_max - in_min) * (out_max - out_min) + out_min
```

---

**Q5.** `@export`를 사용한 의존성 주입 방식이 하드코딩보다 나은 이유는?

```gdscript
# 하드코딩
@onready var spring_arm = $CameraPivot/SpringArm3D

# @export 주입
@export var spring_arm: SpringArm3D
```

---

**Q6.** 다음 중 리팩토링이 필요한 **증상**이 아닌 것은?

① 기능을 추가할 때마다 10개 이상의 파일을 수정해야 한다  
② 스크립트가 500줄을 넘어 어느 부분이 뭘 하는지 파악하기 어렵다  
③ 게임이 FPS 60으로 안정적으로 돌아간다  
④ 적을 고치다가 의도치 않게 플레이어 코드가 망가진다

---

**Q7.** 높은 결합도(High Coupling)의 문제점을 실제 예시로 설명하라.

---

**Q8.** 다음 Signal 기반 코인 코드에서, HUD가 없어도 게임이 정상 동작하는 이유는?

```gdscript
# coin.gd
signal collected
func _on_area_entered(body):
    if body.is_in_group("player"):
        collected.emit()
        queue_free()
```

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.**
- 코인이 HUD, GameManager, AudioManager를 직접 참조하므로 **강한 결합**이 발생한다
- HUD나 AudioManager가 없으면 즉시 에러가 발생한다
- HUD의 함수 이름이 바뀌면 coin.gd도 수정해야 한다
- 나중에 수집 시 파티클 효과를 추가하려면 coin.gd를 또 수정해야 한다

**Q2.**
1. **재사용성**: `HealthComponent`를 플레이어, 적, 부숴지는 오브젝트 등 어디에든 자식으로 붙여서 재사용할 수 있다. 각 스크립트에 체력 로직을 중복 작성할 필요가 없다.
2. **단일 책임**: 플레이어 스크립트는 이동에만 집중하고, 체력 로직은 `HealthComponent`가 담당한다. 버그 수정이나 수정 범위가 명확해진다.

**Q3.**
- 방식 A(if-else): 상태 조건이 늘어날수록 조건들이 서로 충돌하기 쉽다. 새 상태를 추가하면 기존 모든 조건에 예외를 추가해야 할 수 있다.
- 방식 B(상태 머신): 한 번에 딱 하나의 상태만 활성화된다. 새 상태를 `match` 블록에 케이스 하나만 추가하면 되고, 다른 상태 코드에 영향을 주지 않는다.

**Q4.** `static func`는 인스턴스 없이 클래스 이름으로 바로 호출할 수 있다 (`MathUtils.map_range(...)`). 순수 계산 함수(입력 → 출력, 부작용 없음)는 굳이 노드 인스턴스를 만들 필요가 없으므로 `static`이 적합하다.

**Q5.**
- 하드코딩: 씬 구조가 바뀌면(`SpringArm3D`가 다른 경로로 이동하면) 코드도 수정해야 한다. 또한 이 스크립트를 다른 씬에서 재사용할 때 경로가 달라서 오류가 난다.
- `@export` 주입: Inspector에서 노드를 드래그해서 연결하므로 경로에 의존하지 않는다. 씬 구조가 바뀌어도 Inspector에서 다시 연결하면 코드 수정이 필요 없다.

**Q6.** ③ — FPS 60으로 안정적으로 돌아가는 것은 성능 문제가 없다는 뜻이므로 리팩토링 증상이 아니다. ①②④는 모두 코드 유지보수 문제로 리팩토링이 필요한 증상이다.

**Q7.** 예: `enemy.gd`가 `player.gd`의 내부 변수 `hp`를 직접 수정(`player.hp -= 10`)하면, 나중에 플레이어의 체력 관련 로직이 바뀔 때(예: 방어력 계산 추가) `enemy.gd`도 함께 수정해야 한다. 결합도가 높을수록 한 곳의 변경이 다른 곳을 망가뜨릴 가능성이 높아진다.

**Q8.** `coin.gd`는 `collected` Signal을 발생시킬 뿐, HUD가 있는지 없는지 알지 못하고 관심도 없다. HUD는 이 Signal을 구독해서 반응하지만, 구독자가 0명이어도 Signal 발생 자체는 정상 동작한다. 코인은 HUD에 의존하지 않으므로 HUD가 없어도 에러가 발생하지 않는다.

</details>
