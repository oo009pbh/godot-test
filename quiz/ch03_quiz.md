# Ch03 퀴즈 — GDScript 독해력

---

## 문제

**Q1.** 다음 두 함수의 차이를 설명하라.

```gdscript
func _process(delta: float):
    pass

func _physics_process(delta: float):
    pass
```

---

**Q2.** 아래 코드에서 문제점을 찾고 올바른 코드로 수정하라.

```gdscript
# 나쁜 예
position.x += 0.1
```

---

**Q3.** `@export`를 변수 앞에 붙이면 어떤 효과가 있는가?

① 변수가 외부에서 접근 불가능해진다  
② Inspector에서 해당 변수의 값을 조절할 수 있게 된다  
③ 변수가 자동으로 0으로 초기화된다  
④ 스크립트가 Autoload로 등록된다

---

**Q4.** 다음 라이프사이클 함수 중 씬이 완전히 로드된 후 **딱 1번만** 실행되는 함수는?

① `_process(delta)`  ② `_physics_process(delta)`  ③ `_ready()`  ④ `_input(event)`

---

**Q5.** 다음 코드를 읽고 이 스크립트가 어떤 노드 타입에 붙어있는지 답하라.

```gdscript
extends CharacterBody3D

func _physics_process(delta):
    velocity.y -= 9.8 * delta
    move_and_slide()
```

---

**Q6.** (O/X) `is_action_pressed()`와 `is_action_just_pressed()`는 동일한 방식으로 동작한다.

---

**Q7.** 다음 에러 메시지에서 에러가 발생한 위치(파일명, 줄번호, 함수명)를 찾아라.

```
E 0:00:02:1025   enemy.gd:42 @ _on_area_entered():
  Null instance: call method "take_damage" on a null value
```

---

**Q8.** `_physics_process` 대신 `_process`에서 `move_and_slide()`를 호출하면 어떤 문제가 생기는가?

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.**
- `_process(delta)`: 매 렌더링 프레임마다 호출. 프레임률에 따라 호출 주기가 달라짐. UI 업데이트, 카메라에 적합.
- `_physics_process(delta)`: 물리 엔진 프레임마다 호출. 기본 60Hz로 **고정 주기**. 캐릭터 이동, 충돌 판정에 반드시 사용.

**Q2.** `delta`를 곱하지 않으면 프레임률에 따라 이동 속도가 달라진다.
```gdscript
# 올바른 예
position.x += 6.0 * delta
```

**Q3.** ② Inspector에서 해당 변수의 값을 조절할 수 있게 된다

**Q4.** ③ `_ready()`

**Q5.** `CharacterBody3D` — `extends CharacterBody3D`로 선언되어 있다.

**Q6.** X
- `is_action_pressed()`: 키를 누르고 있는 **동안** 매 프레임 true
- `is_action_just_pressed()`: 키를 누른 **그 프레임만** true (점프처럼 한 번만 실행해야 할 때 사용)

**Q7.**
- 파일명: `enemy.gd`
- 줄번호: `42`
- 함수명: `_on_area_entered()`

**Q8.** `_process`는 호출 주기가 프레임률에 따라 달라지므로, 고프레임에서는 더 빠르고 저프레임에서는 더 느리게 이동한다. 즉, 이동 속도가 프레임률에 종속된다.

</details>
