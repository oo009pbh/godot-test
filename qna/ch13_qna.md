# Ch13 Q&A

---

## Q1. AnimationPlayer 트랙이 코인 위치를 덮어쓰는 이유가 뭐야?

**AnimationPlayer의 트랙 경로가 루트 노드(`"."`)를 가리키면, 씬에서 지정한 위치값을 첫 키프레임 값으로 덮어쓰기 때문이다.**

코인을 `y=1.0`에 배치해도 AnimationPlayer가 시작하자마자 트랙의 첫 키프레임 `y=0.0`을 루트 Area3D에 적용해버린다. 코인이 바닥 속으로 묻혀서 안 보이는 현상이 발생한다.

```gdscript
# 잘못된 트랙 경로 (루트 노드 자체를 움직임)
tracks/0/path = NodePath(".:position:y")

# 올바른 트랙 경로 (자식 MeshInstance3D만 움직임)
tracks/0/path = NodePath("MeshInstance3D:position:y")
```

루트 Area3D는 씬에서 배치한 위치 그대로 있고, 그 안의 MeshInstance3D만 위아래로 부유하게 된다.

---

## Q2. CylinderMesh 코인이 카메라에서 거의 안 보이는 이유는?

**Godot 4의 CylinderMesh는 기본적으로 원반이 XZ 평면에 눕혀진 상태이기 때문에, 수평 방향에서 보면 얇은 선처럼 보인다.**

동전을 바닥에 눕혀놓은 것과 같다. 3인칭 카메라는 플레이어를 거의 수평으로 바라보므로, 얇은 원반의 엣지(edge)만 보여 거의 투명하게 보인다.

```
# coin.tscn의 MeshInstance3D에 X축 90도 회전 적용
transform = Transform3D(1, 0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0)
```

이 행렬은 X축으로 -90도 회전 → 동전이 수직으로 세워져 카메라에 정면이 보인다.

---

## Q3. 코인을 world.tscn에 배치했는데 게임에서 안 나오는 이유는?

**실제 게임이 실행하는 씬은 `world.tscn`이 아니라 `level.tscn`이기 때문이다.**

CLAUDE.md에는 `world.tscn`이 메인 씬이라고 적혀 있었지만, `project.godot`의 실제 메인 씬은 `main_menu.tscn`이다.

```
메인 씬 체인:
main_menu.tscn → (Start 버튼) → level1.tscn → level.tscn
                                              ↑ 코인은 여기에 배치해야 한다
```

새 오브젝트를 배치할 때는 `project.godot`의 `run/main_scene`을 확인하고, 실제 실행 경로를 추적해야 한다.

---

## Q4. 적이 공격해도 체력바가 안 줄어드는 이유는?

**적은 `player.take_damage()`를 호출하고, 플레이어는 내부 `_health`만 줄이고 HUD가 구독하는 `GameManager.health_changed`는 발생시키지 않았기 때문이다.**

신호 연결이 두 갈래로 끊겨있었다.

```
적의 공격 흐름 (버그):
enemy → player.take_damage() → player._health 감소 → player.health_changed 발생
                                                       ↑ HUD는 이걸 안 듣는다

HUD가 듣는 신호:
GameManager.health_changed ← HUD 연결됨

수정 후:
enemy → player.take_damage() → GameManager.take_damage() → GameManager.health_changed → HUD 업데이트
```

```gdscript
# player.gd 수정 전
func take_damage(amount: int) -> void:
    _health = max(0, _health - amount)
    health_changed.emit(_health)   # GameManager에는 전달 안 됨

# player.gd 수정 후
func take_damage(amount: int) -> void:
    GameManager.take_damage(amount)   # GameManager가 신호 발생 → HUD까지 연결
```

---
