# Ch10 Q&A

---

## Q1. 적 AI가 플레이어를 감지 못하고 움직이지 않은 이유가 뭐야?

**Area3D의 collision_mask가 플레이어의 collision_layer와 달라서 교집합이 없었기 때문이다.**

경비원(Area3D)이 "2번 채널 무전기만 듣도록" 설정돼 있는데,
플레이어가 "2번 채널"로 송신하고 있었지만 경비원의 수신기(mask)가 "1번"으로 맞춰져 있어서
아무 신호도 못 받은 상황이다.

```
Player:   collision_layer = 2  (레이어 2에 존재)
Area3D:   collision_mask  = 1  (레이어 1만 감시)  ← 교집합 없음
→ body_entered 신호 영원히 발화 안 됨
```

수정: DetectArea에 `collision_mask = 2` 추가.

```gdscript
# enemy.tscn DetectArea 노드
collision_mask = 2  # 플레이어가 있는 레이어를 감시
```

---

## Q2. body_entered 신호가 왜 씬 시작 시 발화 안 됐나?

**body_entered는 "범위 밖 → 안" 진입 순간에만 발화하고, 처음부터 안에 있으면 발화하지 않는다.**

자동문 센서와 같다. 문 앞에서 걸어 들어올 때 열리지만,
처음부터 문 안에 서 있으면 센서가 반응하지 않는다.

플레이어 시작 위치(0,0,0)와 적 위치(~7~8m)가 감지 범위(10m) 안이어서
씬이 열리는 순간 이미 "안에 있는" 상태라 신호가 발화되지 않았다.

```gdscript
# 해결: 첫 physics 프레임 후 이미 겹쳐있는 바디를 직접 스캔
func _ready() -> void:
    await get_tree().physics_frame
    var overlapping: Array = $DetectArea.get_overlapping_bodies()
    for body in overlapping:
        _on_body_entered(body)
```

---
