# Ch06 퀴즈 — 카메라와 조명

---

## 문제

**Q1.** (O/X) 씬에 `Camera3D`가 없어도 게임 화면에 3D 오브젝트가 정상적으로 표시된다.

---

**Q2.** 3인칭 카메라 Rig의 4노드 구조를 올바르게 나열하라.

```
Player (CharacterBody3D)
└── (A)
    └── (B)
        └── (C)
```

A = `________`, B = `________`, C = `________`

---

**Q3.** `SpringArm3D`의 역할을 "셀카봉" 비유를 사용해 설명하라.

---

**Q4.** 아래 코드가 필요한 이유는?

```gdscript
func _ready():
    $CameraPivot/SpringArm3D.add_excluded_object(get_rid())
```

---

**Q5.** 3인칭 카메라에서 이동 방향을 계산할 때 왜 Y 성분을 0으로 만드는가?

```gdscript
forward.y = 0.0
right.y = 0.0
```

---

**Q6.** 다음 조명 중 "태양처럼 전체에 같은 방향의 빛을 주는" 조명은?

① `OmniLight3D`  ② `SpotLight3D`  ③ `DirectionalLight3D`  ④ `WorldEnvironment`

---

**Q7.** `WorldEnvironment`가 담당하는 기능 3가지를 쓰라.

---

**Q8.** `OmniLight3D`와 `SpotLight3D`의 차이점을 한 문장으로 설명하라.

---

**Q9.** 마우스 감도(sensitivity)를 `0.003`으로 설정했을 때, 다음 코드에서 마우스를 오른쪽으로 100픽셀 움직이면 `CameraPivot.rotation.y`는 얼마나 변하는가?

```gdscript
$CameraPivot.rotation.y -= event.relative.x * 0.003
```

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.** X — 활성화된 `Camera3D`가 없으면 화면이 회색이거나 아무것도 보이지 않는다.

**Q2.**
- A = `CameraPivot (Node3D)` — 회전 중심점
- B = `SpringArm3D` — 벽 감지 + 팔 길이 조절
- C = `Camera3D` — 실제 카메라

**Q3.** SpringArm3D는 카메라를 플레이어 뒤에 일정 거리만큼 띄워두는 역할을 한다. 셀카봉처럼 카메라를 멀리 밀어내다가, 벽이 있으면 자동으로 팔을 짧게 줄여서 카메라가 벽 안으로 들어가지 않게 한다.

**Q4.** SpringArm3D는 경로에 있는 물체를 장애물로 인식하는데, 플레이어 자신의 `CapsuleShape3D`도 장애물로 인식할 수 있다. 그러면 점프/착지 시 카메라가 순간적으로 가까워지는 버그가 발생한다. `add_excluded_object(get_rid())`로 플레이어 자신을 충돌 제외 목록에 추가하면 이 버그가 수정된다.

**Q5.** 카메라가 약간 아래를 내려다보고 있을 때 방향 벡터에 Y 성분이 생긴다. Y를 0으로 만들지 않으면 "앞으로 가" 했을 때 공중으로 뜨거나 땅 속으로 파고드는 현상이 생긴다.

**Q6.** ③ `DirectionalLight3D`

**Q7.** 하늘 배경(Sky), 안개(Fog), 전체 분위기 빛(Ambient Light), Glow(빛 번짐), SSAO 등에서 3가지 선택

**Q8.** `OmniLight3D`는 전구처럼 모든 방향으로 균등하게 빛을 발산하고, `SpotLight3D`는 손전등처럼 특정 방향의 원뿔 형태로 빛을 발산한다.

**Q9.** `rotation.y`가 `-0.3 라디안` 감소한다. (100 × 0.003 = 0.3, 마우스를 오른쪽으로 움직이면 오른쪽을 봐야 하므로 음수 적용)

</details>
