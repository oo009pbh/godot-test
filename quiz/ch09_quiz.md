# Ch09 퀴즈 — 플레이어 컨트롤러

---

## 문제

**Q1.** 3인칭 플레이어 씬에서 `CameraPivot (Node3D)`이 별도로 존재하는 이유는?

---

**Q2.** 아래 코드에서 이동 방향을 카메라 기준으로 변환하는 핵심 줄은 무엇이고, 왜 `y`를 0으로 만드는가?

```gdscript
var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
var cam_basis = camera.global_basis
var move_direction = (cam_basis * Vector3(input.x, 0, input.y)).normalized()
move_direction.y = 0
```

---

**Q3.** `lerp_angle`이 일반 `lerp`보다 캐릭터 회전에 적합한 이유는?

---

**Q4.** (O/X) `is_action_just_pressed("jump")`는 점프 키를 누르고 있는 동안 매 프레임 true를 반환한다.

---

**Q5.** 다음 MouseMode 중 FPS/TPS 게임에서 사용하는 모드는?

① `MOUSE_MODE_VISIBLE`  ② `MOUSE_MODE_HIDDEN`  
③ `MOUSE_MODE_CAPTURED`  ④ `MOUSE_MODE_CONFINED`

---

**Q6.** 더블 점프 구현에서 `jump_count` 변수를 별도로 관리하는 이유는?

---

**Q7.** InputMap을 하드코딩(`Input.is_key_pressed(KEY_W)`) 대신 사용하는 장점은?

---

**Q8.** 상태 머신에서 `State.WALKING` 상태일 때 이동을 막고 싶은 `State.ATTACKING` 상태를 추가하려면 if-else 방식과 비교해 어떤 차이가 있는가?

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.** 플레이어의 좌우(Y축) 회전과 카메라의 상하(X축) 회전을 분리하기 위해서다. `CameraPivot` 없이 `Camera3D`를 플레이어에 직접 붙이면, 위를 바라볼 때 플레이어 몸도 같이 위로 기울어져 어색하다.

**Q2.**
- 핵심 줄: `var move_direction = (cam_basis * Vector3(input.x, 0, input.y)).normalized()` — 입력 벡터를 카메라의 방향 기준으로 변환한다.
- `y = 0`이 필요한 이유: 카메라가 약간 아래를 내려다보고 있으면 방향 벡터에 Y 성분이 생긴다. 그대로 쓰면 "앞으로 가" 했을 때 공중으로 뜨거나 땅 속으로 파고든다.

**Q3.** 각도는 360° = 0°이기 때문에, 350°에서 10°로 회전할 때 일반 `lerp`는 350 → 0 방향으로 거꾸로 돌아간다. `lerp_angle`은 가장 짧은 방향(350 → 360/0 → 10)으로 회전한다.

**Q4.** X — `is_action_just_pressed()`는 키를 **누른 그 프레임만** true를 반환한다. 누르고 있는 동안 매 프레임 true인 것은 `is_action_pressed()`다.

**Q5.** ③ `MOUSE_MODE_CAPTURED` — 마우스를 화면 중앙에 고정하고 커서를 숨긴다.

**Q6.** `is_on_floor()`는 "지금 바닥에 있냐"만 알 수 있고, 몇 번 점프했는지는 알 수 없다. 더블 점프를 구현하려면 공중에서 몇 번 점프했는지 추적하는 별도 변수(`jump_count`)가 필요하다.

**Q7.** 키를 변경하거나 게임패드 지원을 추가할 때 코드를 수정하지 않고 `project.godot`의 InputMap만 변경하면 된다. 코드와 입력 설정이 분리되어 유지보수가 쉽다.

**Q8.** if-else 방식은 `ATTACKING` 상태 조건을 모든 이동/점프 코드에 일일이 추가해야 해서 조건이 기하급수적으로 늘어난다. 상태 머신에서는 `match` 블록에서 `ATTACKING` 케이스를 추가하고, 그 안에서는 이동 코드를 실행하지 않으면 된다.

</details>
