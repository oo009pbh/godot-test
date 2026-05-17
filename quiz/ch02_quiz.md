# Ch02 퀴즈 — 노드 & 씬 시스템

---

## 문제

**Q1.** 다음 중 **충돌은 막지 않고 감지만** 하는 노드는?

① `StaticBody3D`  ② `CharacterBody3D`  ③ `RigidBody3D`  ④ `Area3D`

---

**Q2.** 아래 씬 구조에서 Player가 이동할 때 Camera3D도 함께 이동하는 이유는?

```
Player (CharacterBody3D)
├── MeshInstance3D
├── CollisionShape3D
└── Camera3D
```

---

**Q3.** (O/X) `CollisionShape3D` 없이 `CharacterBody3D`만 있어도 물리 충돌이 정상 동작한다.

---

**Q4.** 다음 코드에서 `@onready`를 사용하는 이유는?

```gdscript
# 나쁜 예
var camera = $Camera3D

# 좋은 예
@onready var camera: Camera3D = $Camera3D
```

---

**Q5.** 씬 인스턴싱(Scene Instancing)의 핵심 장점을 "설계도와 집" 비유를 활용해 설명하라.

---

**Q6.** 다음 Body 노드 중 물리 엔진이 자동으로 움직임을 제어하는 것은?

① `StaticBody3D`  ② `CharacterBody3D`  ③ `RigidBody3D`  ④ `AnimatableBody3D`

---

**Q7.** `Area3D`에서 가장 자주 쓰이는 Signal 2개를 쓰라.

---

**Q8.** 다음 중 **씬 라이프사이클 순서**로 올바른 것은?

① `_ready()` → `_process()` → 씬 로드  
② 씬 로드 → `_ready()` → `_process()` 반복  
③ `_process()` → `_ready()` → 씬 로드  
④ 씬 로드 → `_process()` 반복 → `_ready()`

---

**Q9.** 씬을 역할별로 분리하는 이유를 한 문장으로 설명하라.

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.** ④ `Area3D` — 다른 Body와 겹칠 수 있고 막지 않는다. Signal을 통해 감지만 한다.

**Q2.** `Camera3D`가 `Player`의 자식 노드이기 때문이다. 부모 노드가 이동하면 자식 노드들도 자동으로 함께 이동한다.

**Q3.** X — `CollisionShape3D` 없이는 물리 엔진이 충돌 범위를 알 수 없어서 충돌이 동작하지 않는다.

**Q4.** 변수를 선언하는 시점(`_ready()` 이전)에는 씬 트리가 아직 완전히 준비되지 않아 `$Camera3D` 같은 노드 참조가 `null`이 될 수 있다. `@onready`는 `_ready()` 직전에 안전하게 할당해준다.

**Q5.** `.tscn` 파일은 설계도 1장이고, 이 설계도로 씬에 인스턴스를 여러 개 배치할 수 있다. 설계도(`.tscn`)를 수정하면 그 설계도로 만든 모든 인스턴스가 자동으로 반영된다.

**Q6.** ③ `RigidBody3D` — 물리 법칙(중력, 마찰, 충돌 반동)을 엔진이 자동 처리한다.

**Q7.** `body_entered` (물체가 Area3D 안으로 들어올 때), `body_exited` (물체가 Area3D 밖으로 나갈 때)

**Q8.** ② 씬 로드 → `_ready()` → `_process()` 반복

**Q9.** 큰 씬 하나에 모든 것을 넣으면 수정하기 어렵고 재사용이 불가능하다. 역할별로 씬을 분리하면 수정 범위가 좁아지고 여러 곳에서 재사용할 수 있다.

</details>
