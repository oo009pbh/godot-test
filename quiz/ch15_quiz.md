# Ch15 퀴즈 — 씬 전환 & 세이브/불러오기

---

## 문제

**Q1.** `res://`와 `user://`의 차이를 정리하라.

| | `res://` | `user://` |
|--|---------|---------|
| 위치 | ? | ? |
| 읽기 | ? | ? |
| 쓰기 (빌드 후) | ? | ? |
| 용도 | ? | ? |

---

**Q2.** (O/X) 배포된 게임에서 `res://save.json` 경로에 세이브 파일을 저장할 수 있다.

---

**Q3.** 세이브 데이터 형식으로 JSON을 사용하는 이유를 2가지 이상 쓰라.

---

**Q4.** 다음 세이브 코드에서 `file.close()`를 반드시 호출해야 하는 이유는?

```gdscript
var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
if file:
    file.store_string(JSON.stringify(save_data, "\t"))
    file.close()  # ← 왜 필요한가?
```

---

**Q5.** `PackedScene.instantiate()`와 `PackedScene.new()`의 차이를 설명하라.

---

**Q6.** 아래 스포너 코드에서 `get_tree().current_scene.add_child(enemy)`를 쓰는 이유는? `add_child(enemy)`(자기 자신에 추가)가 안 되는 이유도 설명하라.

```gdscript
func spawn_enemy(at_position: Vector3) -> void:
    var enemy = enemy_scene.instantiate()
    get_tree().current_scene.add_child(enemy)
    enemy.global_position = at_position
```

---

**Q7.** 페이드 씬 전환에서 `is_transitioning` 플래그가 필요한 이유는?

---

**Q8.** 레벨 데이터를 `level1.json` 같은 외부 파일로 분리하면 좋은 이유는?

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.**

| | `res://` | `user://` |
|--|---------|---------|
| 위치 | 게임 설치/프로젝트 폴더 | 사용자 데이터 폴더 (OS별 다름) |
| 읽기 | O | O |
| 쓰기 (빌드 후) | X (패키징되어 불가) | O |
| 용도 | 씬, 스크립트, 에셋 등 게임 파일 | 세이브 파일, 설정, 스크린샷 |

**Q2.** X — 배포된 게임은 파일이 패키징되어 있어서 `res://` 안에 새 파일을 만들 수 없다. 세이브 파일은 반드시 `user://`에 저장해야 한다.

**Q3.**
- 사람이 읽을 수 있는 텍스트 형식이라 디버깅이 쉽다
- GDScript의 Dictionary와 직접 변환이 가능하다 (`JSON.stringify()`, `JSON.parse_string()`)
- 텍스트 에디터로도 편집/확인이 가능하다 (그 중 2가지 이상)

**Q4.** 파일에 쓴 데이터가 OS의 버퍼에 남아있을 수 있다. `close()`를 호출해야 버퍼가 디스크에 완전히 기록(flush)되고 파일 핸들이 해제된다. 닫지 않으면 데이터 손실 또는 파일 손상이 발생할 수 있다.

**Q5.**
- `PackedScene.instantiate()`: 씬 파일(`.tscn`)을 설계도로 사용해서 **새로운 인스턴스**(독립적인 복사본)를 생성한다.
- `PackedScene.new()`: PackedScene 리소스 자체를 새로 만드는 것으로, 씬을 인스턴스화하는 게 아니라 빈 PackedScene 객체를 만든다.

**Q6.** Spawner 스크립트는 레벨 씬의 특정 위치에 있는 노드다. `add_child(enemy)`로 Spawner 자신의 자식으로 추가하면 적이 Spawner의 로컬 좌표 기준으로 배치된다. 또한 Spawner가 삭제되면 모든 적도 함께 삭제된다. `get_tree().current_scene.add_child(enemy)`로 씬 루트에 추가해야 독립적인 레벨 오브젝트로 정상 동작한다.

**Q7.** 전환 애니메이션 도중에 다시 전환이 호출되면 여러 전환이 중첩 실행되어 버그가 발생할 수 있다. `is_transitioning = true` 플래그로 전환 중에는 추가 전환 요청을 무시한다.

**Q8.** 코드를 수정하지 않고 JSON 파일만 수정해서 레벨 디자인(적 수, 스폰 위치, BGM 등)을 변경할 수 있다. 기획자나 디자이너가 코드 없이도 레벨을 조정할 수 있어 개발 유연성이 높아진다.

</details>
