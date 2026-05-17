# Ch05 정답 — 3D 좌표계와 Transform

**Q1.** ② -Y

중력은 아래 방향이고, Godot에서 아래는 -Y다.

---

**Q2.** `normalized()`가 없어서 대각선 이동 시 속도가 약 1.41배 더 빠르다(피타고라스 정리).

```gdscript
# 올바른 코드
var direction = Vector3(1, 0, 1).normalized()
velocity = direction * 5.0
```

---

**Q3.**
- `position`: 부모 노드 기준 **상대(로컬) 위치**
- `global_position`: 월드 원점(0,0,0) 기준 **절대 위치**

두 오브젝트 사이의 거리 계산 등에는 `global_position`을 사용해야 정확하다.

---

**Q4.** 현재 위치에서 플레이어를 향하는 **방향 벡터(크기 1)**를 구한다.

공식: `(목표 위치 - 현재 위치).normalized()`

---

**Q5.**
- `1.0`에 가까울수록: 두 벡터가 **같은 방향**
- `-1.0`에 가까울수록: 두 벡터가 **완전히 반대 방향**
- `0.0`이면: 두 벡터가 **90도 수직**

---

**Q6.** X

Godot에서 노드의 앞 방향은 **`-global_transform.basis.z`** (음수 Z)다. Godot의 기본 앞 방향이 -Z이기 때문이다.

---

**Q7.** ② `player.global_position.distance_to(enemy.global_position)`

두 월드 좌표 사이의 거리를 구하려면 `global_position`을 써야 한다.

---

**Q8.** `lerp`는 매 프레임 현재 위치에서 목표 위치까지의 남은 거리를 일정 비율만큼만 이동한다. 목표에 가까워질수록 이동 거리가 줄어들어(지수적 감소) 부드럽게 수렴하는 효과가 생긴다.
