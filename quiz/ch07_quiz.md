# Ch07 퀴즈 — 3D 물리 & 충돌

---

## 문제

**Q1.** 다음 설명에 맞는 Body 노드를 연결하라.

| 설명 | 노드 |
|------|------|
| 코드로 직접 이동 제어, 플레이어에 사용 | ? |
| 절대 안 움직임, 바닥/벽에 사용 | ? |
| 물리 엔진이 자동으로 움직임, 공/상자에 사용 | ? |
| 충돌 없이 감지만 함, 아이템 획득 범위에 사용 | ? |

---

**Q2.** (O/X) `MeshInstance3D`가 있으면 `CollisionShape3D` 없이도 물리 충돌이 동작한다.

---

**Q3.** `move_and_slide()`가 하는 일 3가지를 설명하라.

---

**Q4.** 다음 코드에서 `move_and_slide()` 이후에 `is_on_floor()`를 호출하는 이유는?

```gdscript
func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= 9.8 * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = 5.0

    move_and_slide()
    # is_on_floor() 결과를 여기서 읽어야 정확함
```

---

**Q5.** 충돌 Layer와 Mask의 차이를 설명하라.

---

**Q6.** 캐릭터 충돌 모양으로 `CapsuleShape3D`를 주로 사용하는 이유는?

---

**Q7.** `Area3D`에서 `queue_free()`를 사용하는 아래 코드를 읽고, `free()`대신 `queue_free()`를 사용하는 이유를 설명하라.

```gdscript
func _on_body_entered(body):
    if body.is_in_group("player"):
        GameManager.collect_coin()
        queue_free()
```

---

**Q8.** 총알 오브젝트가 다른 총알과 충돌하면 안 되고, 적(Layer 3)과 바닥(Layer 1)에만 맞아야 할 때, 총알의 Collision 설정은?

- Collision Layer: `________`
- Collision Mask: `________`

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.**
- `CharacterBody3D` — 코드로 직접 이동 제어
- `StaticBody3D` — 절대 안 움직임
- `RigidBody3D` — 물리 엔진이 자동으로 움직임
- `Area3D` — 충돌 없이 감지만 함

**Q2.** X — Godot의 물리 엔진은 눈에 보이는 메시(Mesh)를 무시하고 `CollisionShape3D`만 본다. `CollisionShape3D` 없이는 충돌이 동작하지 않는다.

**Q3.**
1. **이동**: `velocity * delta`만큼 캐릭터를 실제로 움직인다
2. **충돌 감지**: 이동 경로에 다른 오브젝트가 있는지 확인한다
3. **슬라이드**: 충돌 시 멈추지 않고 충돌면을 따라 미끄러진다

**Q4.** `is_on_floor()`는 `move_and_slide()`가 호출된 후에야 정확한 값을 반환한다. `move_and_slide()`를 실행해야 Godot가 "이 캐릭터가 바닥에 닿아있나?"를 계산하기 때문이다.

**Q5.**
- **Layer**: "나는 몇 번 그룹이다" (자신이 속한 그룹)
- **Mask**: "나는 몇 번 그룹과 충돌한다" (반응할 그룹)

**Q6.** 사람 형태를 정확히 따라가는 복잡한 모양 대신 캡슐로 단순화하면 모서리가 없어서, 계단이나 경사면에서 자연스럽게 올라갈 수 있다.

**Q7.** `free()`는 즉시 삭제하므로 같은 프레임에 이 노드를 참조하는 다른 코드가 있으면 오류가 발생할 수 있다. `queue_free()`는 현재 프레임의 처리가 모두 끝난 뒤 안전하게 삭제한다.

**Q8.**
- Collision Layer: `4` (총알은 4번 그룹)
- Collision Mask: `1, 3` (바닥 Layer 1, 적 Layer 3에만 반응)

</details>
