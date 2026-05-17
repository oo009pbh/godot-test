# Ch03 정답 — GDScript 독해력

**Q1.**
- `_process(delta)`: 매 렌더링 프레임마다 호출. 프레임률에 따라 주기가 달라짐. UI, 카메라에 적합.
- `_physics_process(delta)`: 물리 엔진 프레임마다 호출. 기본 60Hz **고정 주기**. 캐릭터 이동, 충돌 판정에 반드시 사용.

---

**Q2.** `delta`를 곱하지 않으면 프레임률에 따라 이동 속도가 달라지는 버그가 생긴다.

```gdscript
# 올바른 코드
position.x += 6.0 * delta
```

---

**Q3.** ② Inspector에서 해당 변수의 값을 조절할 수 있게 된다

---

**Q4.** ③ `_ready()`

씬이 완전히 로드된 후 딱 1번만 실행된다.

---

**Q5.** `CharacterBody3D`

`extends CharacterBody3D`로 선언되어 있다.

---

**Q6.** X

- `is_action_pressed()`: 키를 누르고 있는 **동안** 매 프레임 true
- `is_action_just_pressed()`: 키를 누른 **그 프레임만** true (점프처럼 한 번만 실행해야 할 때 사용)

---

**Q7.**
- 파일명: `enemy.gd`
- 줄번호: `42`
- 함수명: `_on_area_entered()`

---

**Q8.** `_process`는 프레임률에 따라 호출 주기가 달라지므로, 고프레임에서는 더 빠르고 저프레임에서는 더 느리게 이동한다. 이동 속도가 프레임률에 종속된다.
