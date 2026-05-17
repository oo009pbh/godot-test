# Ch11 퀴즈 — 게임 상태 관리

---

## 문제

**Q1.** 씬을 전환하면 점수 데이터가 사라지는 이유와 해결 방법은?

---

**Q2.** Autoload의 특징을 "건물 안내데스크" 비유로 설명하라.

---

**Q3.** 다음 `GameManager` 코드에서 `take_damage(20)`을 호출했을 때 일어나는 일을 순서대로 설명하라.

```gdscript
var health: int = 100
signal health_changed(new_health: int)
signal game_over

func take_damage(amount: int) -> void:
    health -= amount
    health = max(0, health)
    health_changed.emit(health)
    if health <= 0:
        game_over.emit()
```

---

**Q4.** `get_tree().paused = true`로 일시정지했을 때, 일시정지 메뉴의 버튼이 반응하지 않는 이유와 해결 방법은?

---

**Q5.** 아래 씬 전환 코드에서 `await tween.finished`가 필요한 이유는?

```gdscript
func transition_to(scene_path: String) -> void:
    var tween = create_tween()
    tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
    await tween.finished  # ← 왜 필요한가?
    get_tree().change_scene_to_file(scene_path)
```

---

**Q6.** `create_timer(2.0)`과 `Timer` 노드의 차이를 설명하라.

---

**Q7.** 다음 두 방식 중 Signal 방식이 더 나은 이유를 설명하라.

```gdscript
# 방식 A: 직접 참조
$"../HUD".update_score(score)

# 방식 B: Signal
GameManager.add_score(100)  # GameManager가 score_changed Signal 발생 → HUD가 자동 업데이트
```

---

**Q8.** `get_tree().reload_current_scene()`과 `get_tree().change_scene_to_file("res://scenes/level1.tscn")`의 차이는?

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.** 씬이 전환되면 기존 씬의 모든 노드가 삭제된다. 점수를 저장하던 노드도 사라지므로 데이터가 초기화된다. 해결 방법: **Autoload(싱글톤)**에 데이터를 저장한다. Autoload는 씬이 바뀌어도 계속 살아있다.

**Q2.** 건물 어느 방에서든 안내데스크에 전화할 수 있듯, Autoload는 어떤 씬에서든 `GameManager.변수`나 `GameManager.함수()`로 접근 가능하다. 씬이 바뀌어도 Autoload는 계속 살아있다.

**Q3.**
1. `health`가 100 - 20 = 80으로 감소
2. `max(0, 80)` 계산 → 0 아래로 내려가지 않음 (결과: 80)
3. `health_changed` Signal을 80과 함께 발생 → HUD가 체력바를 80으로 업데이트
4. health(80) > 0 이므로 `game_over` Signal은 발생하지 않음

**Q4.** `get_tree().paused = true`로 멈추면 모든 노드의 `_process`가 멈추므로 버튼도 반응하지 않는다. 해결: 일시정지 메뉴 노드의 Process Mode를 **Always**로 설정하면 게임이 일시정지 중에도 해당 노드는 계속 작동한다.

**Q5.** `await tween.finished`가 없으면 페이드 아웃 애니메이션이 완료되기도 전에 씬 전환이 일어난다. `await`는 Tween이 완전히 끝날 때까지 이 함수를 그 자리에서 일시 대기시킨다(다른 물리/프레임 처리는 계속 진행).

**Q6.**
- `create_timer()`: 코드에서 임시로 한 번 사용. 간단한 지연 처리(사망 후 2초 뒤 제거 등)에 적합.
- `Timer` 노드: 씬에 배치해서 반복 사용, Inspector에서 Wait Time과 루프 여부 설정 가능. 주기적 이벤트(공격 쿨다운 등)에 적합.

**Q7.**
- 방식 A(직접 참조): HUD가 없으면 바로 에러가 발생한다. Enemy 코드가 HUD의 구체적인 구조를 알아야 한다.
- 방식 B(Signal): HUD가 없어도 GameManager 코드는 문제없이 실행된다. HUD를 수정해도 Enemy 코드를 건드릴 필요가 없다. 나중에 추가 기능(사운드, 로그 등)도 Signal 하나에 구독자를 추가하기만 하면 된다.

**Q8.**
- `reload_current_scene()`: 현재 로드된 씬을 **처음부터 다시** 실행 (재시작)
- `change_scene_to_file(...)`: **다른 씬** 파일로 전환

</details>
