# Ch17 퀴즈 — 미니 프로젝트: 3인칭 어드벤처

---

## 문제

**Q1.** 미니 프로젝트에서 `GameManager.reset()`을 `level1.tscn`의 `_ready()` **가장 첫 번째**로 호출해야 하는 이유는?

---

**Q2.** 코인 수집 시 `Area3D`의 `body_entered` Signal에서 아래 조건이 필요한 이유는?

```gdscript
func _on_body_entered(body):
    if body.is_in_group("player"):
        GameManager.collect_coin()
```

---

**Q3.** 다음 중 미니 프로젝트에서 적이 움직이지 않을 때 가장 먼저 확인해야 할 것은?

① 적의 색상이 올바른지 확인  
② NavigationMesh Bake를 에디터에서 했는지 확인  
③ `project.godot`에 메인 씬이 설정되어 있는지 확인  
④ 코인의 Collision Layer 설정

---

**Q4.** 미니 프로젝트의 씬 구조에서 `GameManager Signal → game_over/level_clear 씬 전환` 연결을 `level1.tscn`의 `_ready()`에서 하는 이유는?

---

**Q5.** SpringArm3D 착지 버그(점프 후 착지 시 카메라가 순간 가까워지는 현상)의 원인과 해결법은?

---

**Q6.** 코인 Area3D가 플레이어를 감지하지 못할 때 확인할 사항 3가지를 쓰라.

---

**Q7.** 미니 프로젝트 완성 체크리스트에서 다음 기능이 구현되려면 어떤 컴포넌트들이 필요한지 설명하라.

> "코인에 닿으면 수집 애니메이션 + HUD 카운터 증가"

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.** `GameManager.reset()`이 늦게 호출되면 이전 게임의 health, score, coin_count 값이 그대로 남아있을 수 있다. 특히 health가 이미 0이라면 씬이 로드되자마자 game_over Signal이 발생할 수 있다. `_ready()` 첫 줄에서 호출하면 씬 시작 시 항상 깨끗한 상태로 시작된다.

**Q2.** Area3D는 모든 종류의 Body가 진입할 때 Signal을 발생시킨다. 적이나 다른 오브젝트가 코인 Area에 닿아도 Signal이 발생하므로, `is_in_group("player")` 조건으로 플레이어가 진입했을 때만 수집 처리를 하도록 제한한다.

**Q3.** ② NavigationMesh Bake를 에디터에서 했는지 확인 — Bake가 없으면 NavigationAgent3D가 경로를 계산하지 못해 적이 이동하지 않는다.

**Q4.** `level1.tscn`이 로드될 때 GameManager의 Signal을 연결해야, 이후 게임 중 game_over나 level_clear Signal이 발생했을 때 씬 전환이 일어난다. `_ready()`에서 연결하지 않으면 Signal이 발생해도 씬 전환 함수가 호출되지 않는다.

**Q5.**
- **원인**: SpringArm3D의 레이캐스트가 착지 순간 플레이어 자신의 CapsuleShape3D를 장애물로 인식해서 팔을 압축한다.
- **해결**: `_ready()`에서 `$CameraPivot/SpringArm3D.add_excluded_object(get_rid())`를 호출해 플레이어 자신을 SpringArm3D 충돌 제외 목록에 추가한다.

**Q6.**
1. 플레이어가 `player` 그룹에 추가되어 있는지 확인
2. `coin.gd`의 `body_entered`에서 `body.is_in_group("player")` 조건이 있는지 확인
3. Collision Layer/Mask 설정이 서로 맞는지 확인 (코인 Area3D의 Mask가 플레이어 Layer를 포함하는지)

**Q7.**
- **코인 수집 애니메이션**: `coin.gd`에서 Tween으로 위로 올라가며 투명해지는 효과 + `queue_free()`
- **HUD 카운터 증가**: `GameManager.collect_coin()` 호출 → `coin_collected` Signal 발생 → `hud.gd`가 Signal을 받아 코인 Label 텍스트 업데이트

</details>
