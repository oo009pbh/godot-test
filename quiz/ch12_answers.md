# Ch12 정답 — UI / HUD

**Q1.** `CanvasLayer`는 3D 렌더링 위에 2D 레이어를 덮는 시스템이다. 카메라가 어디를 보든 관계없이 항상 화면에 고정되어 체력바나 점수가 화면 이동 없이 제자리에 표시된다.

---

**Q2.**
- `Label` → ② 텍스트 표시 (점수, 체력 숫자)
- `ProgressBar` → ④ 막대 형태 진행도 (체력바, 경험치바)
- `ColorRect` → ① 페이드 오버레이, 반투명 배경
- `VBoxContainer` → ③ 버튼/항목을 세로로 자동 정렬

---

**Q3.**
- 체력바: `Top Left`
- 크로스헤어: `Center`

---

**Q4.** GameManager의 Signal에 HUD 함수를 연결해두면, 점수나 체력이 바뀔 때마다 GameManager가 Signal을 발생시키고 HUD가 자동으로 업데이트된다. 매 프레임 `_process()`에서 값을 확인(폴링)하는 것보다 효율적이고, HUD와 GameManager의 결합도를 낮출 수 있다. 마지막 줄은 씬 로드 시 현재 상태를 초기 반영한다.

---

**Q5.** X

`Pausable` 모드는 게임이 일시정지되면 함께 멈춘다. 일시정지 중에도 작동해야 하는 노드는 Process Mode를 **Always**로 설정해야 한다.

---

**Q6.** `parallel()`은 이전 Tween과 **동시에** 실행되게 한다. 이 코드는 0.8초 동안 라벨이 위로 올라가면서(position.y) **동시에** 투명해진다(modulate:a). `parallel()` 없이는 순차 실행(올라간 후 → 투명해짐)이 된다.

---

**Q7.** `%` 연산자는 씬 트리에서 노드 위치가 바뀌어도 "Unique Name"으로 참조하므로 경로가 깨지지 않는다. `$HealthBar`는 씬 패널에서 노드를 다른 부모 아래로 옮기면 참조가 깨질 수 있다.

---

**Q8.** 체력이 30을 초과할 때 색상을 다시 흰색(기본)으로 복원해야 한다.

```gdscript
else:
    health_bar.modulate = Color.WHITE
```
