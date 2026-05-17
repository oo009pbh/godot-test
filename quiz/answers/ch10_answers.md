# Ch10 정답 — 적 AI & 내비게이션

**Q1.** NavigationMesh Bake가 없으면 `NavigationAgent3D`가 경로를 계산하지 못해 적이 플레이어를 추격하지 못한다(제자리에 서거나 이상하게 움직인다).

---

**Q2.** 플레이어 위치로 직접 이동하면 벽, 장애물을 뚫고 지나간다. `get_next_path_position()`은 NavigationMesh의 걸을 수 있는 경로를 따라 벽을 피해 돌아가는 다음 지점을 반환한다.

---

**Q3.** `DetectionArea`(감지 반경 구형 Area3D)에 `player` 그룹에 속한 오브젝트가 진입했을 때 `CHASE` 상태로 전환된다.

---

**Q4.** O

`Area3D`는 벽을 무시하고 반경 내에 있으면 감지한다. 벽 너머 플레이어 감지를 막으려면 `RayCast3D`를 추가로 사용해야 한다.

---

**Q5.** `120도`

`cos(60°) = 0.5`이고, `half_fov = cos(fov_degrees / 2)`이므로 `fov_degrees / 2 = 60°`, 따라서 `fov_degrees = 120°`

---

**Q6.** Timer 노드는 Godot Signal과 연결이 간단하고(`timeout.connect()`), Inspector에서 Wait Time을 시각적으로 설정할 수 있어 코드 가독성이 높다. `delta` 누적 방법은 매 프레임 변수를 계산해야 하고 코드가 더 복잡해진다.

---

**Q7.** 그룹으로 노드를 찾으면 노드의 이름이나 씬 트리 위치에 관계없이 `"player"` 태그로 검색할 수 있다. 직접 참조보다 유연하고, 플레이어 씬 구조가 변경되어도 코드를 수정할 필요가 없다.

---

**Q8.** `free()`는 즉시 삭제되어 같은 프레임에 이 노드를 참조하는 코드(예: 공격 중인 다른 코드)가 있으면 "Null instance" 오류가 발생한다. `queue_free()`는 현재 프레임 처리가 끝난 후 안전하게 삭제된다.

---

**Q9.** `RayCast3D`의 `target_position`은 **로컬(자기 기준) 좌표**를 요구한다. 플레이어의 `global_position`은 월드 좌표이므로, `to_local()`로 적 기준 좌표로 변환해야 한다.
