# Ch12 퀴즈 — UI / HUD

---

## 문제

**Q1.** HUD(체력바, 점수 등)를 `CanvasLayer` 안에 넣는 이유는?

---

**Q2.** 다음 Control 노드와 용도를 연결하라.

| 노드 | 용도 |
|------|------|
| `Label` | ? |
| `ProgressBar` | ? |
| `ColorRect` | ? |
| `VBoxContainer` | ? |

① 페이드 오버레이, 반투명 배경  
② 텍스트 표시 (점수, 체력 숫자)  
③ 버튼/항목을 세로로 자동 정렬  
④ 막대 형태 진행도 (체력바, 경험치바)

---

**Q3.** Anchor 프리셋 중 체력바(왼쪽 위)와 크로스헤어(화면 중앙)에 적합한 것은?

- 체력바: `________`
- 크로스헤어: `________`

---

**Q4.** 다음 HUD 스크립트를 읽고, `_ready()`에서 Signal을 연결하는 이유를 설명하라.

```gdscript
func _ready() -> void:
    GameManager.score_changed.connect(_on_score_changed)
    GameManager.health_changed.connect(_on_health_changed)
    health_bar.value = GameManager.health
```

---

**Q5.** (O/X) `get_tree().paused = true` 상태에서도 Process Mode가 `Pausable`인 노드의 버튼은 정상 작동한다.

---

**Q6.** 다음 Tween 코드에서 `parallel()`의 역할은?

```gdscript
var tween = create_tween()
tween.tween_property(label, "position:y", pos.y - 50, 0.8)
tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
```

---

**Q7.** `%HealthBar`처럼 `%` 연산자를 쓰는 이유는 `$HealthBar`와 비교해 어떤 장점이 있는가?

---

**Q8.** 아래처럼 체력이 30 이하일 때 빨간색으로 바꾸는 코드에서, 체력이 회복되어 30을 초과할 때는 어떤 처리가 필요한가?

```gdscript
func _on_health_changed(new_health: int) -> void:
    health_bar.value = new_health
    if new_health < 30:
        health_bar.modulate = Color.RED
```

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.** `CanvasLayer`는 3D 렌더링 위에 2D 레이어를 덮는 시스템이다. 카메라가 어디를 보든 관계없이 항상 화면에 고정되어 체력바나 점수가 화면 이동 없이 제자리에 표시된다.

**Q2.**
- `Label` → ② 텍스트 표시
- `ProgressBar` → ④ 막대 형태 진행도
- `ColorRect` → ① 페이드 오버레이, 반투명 배경
- `VBoxContainer` → ③ 세로 자동 정렬

**Q3.**
- 체력바: `Top Left`
- 크로스헤어: `Center`

**Q4.** GameManager의 Signal에 HUD 함수를 연결해두면, 점수나 체력이 바뀔 때마다 GameManager가 Signal을 발생시키고 HUD가 자동으로 업데이트된다. 매 프레임 `_process()`에서 값을 확인(폴링)하는 것보다 효율적이고, HUD와 GameManager의 결합도를 낮출 수 있다. 마지막 줄 `health_bar.value = GameManager.health`는 씬 로드 시 현재 상태를 초기 반영한다.

**Q5.** X — `Pausable` 모드는 게임이 일시정지되면 함께 멈춘다. 일시정지 중에도 작동해야 하는 노드는 Process Mode를 **Always**로 설정해야 한다.

**Q6.** `parallel()`은 이전 Tween과 **동시에** 실행되게 한다. 이 코드는 0.8초 동안 라벨이 위로 올라가면서(position.y) **동시에** 투명해진다(modulate:a). `parallel()` 없이는 순차 실행(올라간 후 투명해짐)이 된다.

**Q7.** `%` 연산자는 씬 트리에서 노드 위치가 바뀌어도 "Unique Name"으로 참조하므로 경로가 깨지지 않는다. `$HealthBar`는 씬 패널에서 노드를 다른 부모 아래로 옮기면 참조가 깨질 수 있다.

**Q8.** 체력이 30을 초과할 때 색상을 다시 흰색(기본)으로 복원해야 한다.
```gdscript
else:
    health_bar.modulate = Color.WHITE
```

</details>
