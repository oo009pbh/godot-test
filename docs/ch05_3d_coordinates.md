# Ch05 — 3D 좌표계와 Transform

---

## 개념

### Godot의 3D 좌표계
```
        Y (위)
        │
        │
        └──── X (오른쪽)
       ╱
      ╱
    Z (앞쪽, 화면 밖으로 나오는 방향)
```

- **X**: 왼쪽(-) / 오른쪽(+)
- **Y**: 아래(-) / 위(+)
- **Z**: 앞(+) / 뒤(-)  ← 주의: 유니티와 반대

### Vector3
3D 공간의 위치 또는 방향을 나타내는 값.

```gdscript
Vector3(x, y, z)

Vector3(0, 0, 0)    # 원점
Vector3(1, 0, 0)    # X축 방향 (오른쪽)
Vector3(0, 1, 0)    # Y축 방향 (위)
Vector3(0, 0, 1)    # Z축 방향 (앞)

# 자주 쓰는 상수
Vector3.ZERO    # (0, 0, 0)
Vector3.UP      # (0, 1, 0)
Vector3.FORWARD # (0, 0, -1)  ← Godot에서 "앞"은 -Z
```

### Transform3D — 노드의 위치/회전/크기 묶음
Inspector에서 Node3D를 선택하면 보이는 **Transform** 섹션:

| 속성 | 타입 | 설명 |
|------|------|------|
| `position` | Vector3 | 위치 (x, y, z) |
| `rotation` | Vector3 | 회전 (라디안) |
| `rotation_degrees` | Vector3 | 회전 (도 단위, Inspector에 표시됨) |
| `scale` | Vector3 | 크기 배율 |

```gdscript
# 코드에서 Transform 다루기
position = Vector3(0, 1, 0)          # 위치 설정
position.y += 0.1                     # Y만 이동
rotation_degrees.y = 90               # Y축으로 90도 회전
scale = Vector3(2, 2, 2)              # 2배 크기
```

### 전역 vs 로컬 좌표
- **Local (로컬)**: 부모 기준의 상대 좌표
- **Global (전역)**: 월드 원점 기준 절대 좌표

```gdscript
position           # 로컬 위치 (부모 기준)
global_position    # 전역 위치 (월드 기준)

# 두 오브젝트 사이의 거리
var dist = global_position.distance_to(target.global_position)
```

### 거리 계산 활용 예
```gdscript
# 적이 플레이어에게 가까워지면 공격
var distance = global_position.distance_to(player.global_position)
if distance < 2.0:
    attack()
```

---

## 실습

### 실습 5-1: 좌표 시각적 확인
Claude에게 다음 요청:

> "Godot 4에서 3D 좌표계를 시각적으로 확인하는 씬을 만들어줘.
> 원점에 흰색 구, X=3에 빨간 구, Y=3에 초록 구, Z=3에 파란 구를 배치해줘.
> 각 구 옆에 Label3D로 좌표값도 표시해줘.
> `res://scenes/coordinate_test.tscn`으로 저장해줘."

실행 후 어떤 방향이 X, Y, Z인지 눈으로 확인한다.

### 실습 5-2: 코드로 오브젝트 이동
Claude에게 다음 요청:

> "실습 5-1 씬에 스크립트를 추가해줘.
> 실행하면 빨간 구가 초당 1씩 X축으로 이동하고,
> X = 6에 도달하면 다시 X = 0으로 돌아오게 해줘."

---

## 확인 포인트
- [ ] Godot에서 Y가 위쪽, Z가 앞쪽(화면 밖)인 것을 안다
- [ ] `position`과 `global_position`의 차이를 안다
- [ ] `Vector3.UP`이 `Vector3(0, 1, 0)`임을 안다
- [ ] Inspector의 Transform 섹션에서 위치를 직접 수정할 수 있다

## 다음 챕터
[Ch06 — 카메라와 조명](./ch06_camera_and_lighting.md)
