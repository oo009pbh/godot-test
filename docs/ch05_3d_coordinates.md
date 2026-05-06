# Ch05 — 3D 좌표계와 Transform

> 3D 게임에서 "어디에" "어느 방향으로" "얼마나 크게" 를 표현하는 방법을 이해한다.
> 이 개념을 모르면 적이 플레이어를 향해 이동하거나 총알 방향을 계산하는 코드를 읽을 수 없다.

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
- **Y**: 아래(-) / 위(+) — 점프, 중력 방향
- **Z**: 뒤(-) / 앞(+) — **주의: Unity와 반대!**

**실용적인 기억법:**
- Y = 위/아래 (중력이 -Y 방향)
- X = 좌/우 (오른쪽이 +)
- Z = 앞/뒤 (Godot에서 앞이 -Z, 뒤가 +Z)

---

### Vector3 — 위치와 방향을 동시에 표현

`Vector3(x, y, z)`는 두 가지 의미로 쓰인다:
1. **위치**: "이 좌표에 있다" (예: `position = Vector3(3, 1, 5)`)
2. **방향**: "이 방향으로 가고 있다" (예: `velocity = Vector3(0, -9.8, 0)`)

```gdscript
Vector3(x, y, z)

Vector3(0, 0, 0)    # 원점 (0, 0, 0)
Vector3(3, 0, 0)    # X=3 위치 (오른쪽)
Vector3(0, 2, 0)    # Y=2 위치 (2유닛 위)
Vector3(0, 0, 5)    # Z=5 위치 (앞쪽)

# 자주 쓰는 상수 (외워두면 편함)
Vector3.ZERO     # (0, 0, 0) — 원점
Vector3.UP       # (0, 1, 0) — 위 방향
Vector3.DOWN     # (0, -1, 0) — 아래 방향 (중력)
Vector3.RIGHT    # (1, 0, 0) — 오른쪽
Vector3.LEFT     # (-1, 0, 0) — 왼쪽
Vector3.FORWARD  # (0, 0, -1) — 앞 (Godot에서 앞은 -Z)
Vector3.BACK     # (0, 0, 1) — 뒤
```

---

### 단위 벡터 (Normalized Vector)

방향을 나타낼 때는 **크기가 1인 벡터**를 써야 한다.
그래야 속도를 곱했을 때 일관된 속도가 된다.

```gdscript
# 예: 대각선 이동할 때
var direction = Vector3(1, 0, 1)  # 오른쪽 + 앞 방향
# 이 벡터의 크기는 약 1.41 (피타고라스)
# 속도 5를 곱하면 실제 속도가 7.07이 되어버림 (대각선이 더 빠름)

# 올바른 방법: normalize() 해서 크기를 1로 만들기
direction = direction.normalized()  # 크기 1인 방향 벡터
velocity = direction * 5.0          # 어느 방향이든 속도 5
```

**normalized() 없이 이동하면 대각선이 직선보다 빠른 버그가 발생한다.**

---

### Transform3D — 노드의 위치/회전/크기 묶음

Inspector에서 Node3D를 선택하면 보이는 **Transform** 섹션이 바로 이것이다.

| 속성 | 타입 | 설명 |
|------|------|------|
| `position` | Vector3 | 위치 (x, y, z) |
| `rotation` | Vector3 | 회전 (라디안 단위) |
| `rotation_degrees` | Vector3 | 회전 (도 단위, Inspector에 표시됨) |
| `scale` | Vector3 | 크기 배율 (1.0 = 기본) |
| `global_position` | Vector3 | 월드 기준 절대 위치 |
| `global_rotation` | Vector3 | 월드 기준 절대 회전 |

```gdscript
# 코드에서 Transform 다루기
position = Vector3(0, 1, 0)        # 위치를 (0,1,0)으로 설정
position.y += 0.1                  # Y만 0.1 증가
position += Vector3(1, 0, 0)       # X를 1 증가 (오른쪽으로)

rotation_degrees.y = 90            # Y축으로 90도 회전 (왼쪽 바라봄)
rotation_degrees.y += 45           # Y 회전을 45도 더 추가

scale = Vector3(2, 2, 2)           # 2배 크기로
scale = Vector3(1, 2, 1)           # Y만 2배 (키만 2배)
```

---

### 전역(Global) vs 로컬(Local) 좌표

**비유: 건물 안의 방**
- 로컬: "내 방에서 오른쪽으로 3m" (방 기준)
- 전역: "서울시 강남구 X도 Y도" (지구 기준)

```gdscript
position           # 로컬 위치 — 부모 노드 기준 상대 위치
global_position    # 전역 위치 — 월드 원점 기준 절대 위치

rotation           # 로컬 회전 — 부모 기준
global_rotation    # 전역 회전 — 월드 기준
```

**언제 어느 것을 쓰나:**
```gdscript
# 두 오브젝트 사이의 거리 → 둘 다 global_position 사용
var dist = global_position.distance_to(enemy.global_position)

# 부모 기준으로 위치 설정 → position 사용
position = Vector3(0, 1, 0)   # 부모에서 위로 1

# 발사체 위치 설정 → global_position 사용
bullet.global_position = muzzle.global_position  # 총구 위치에서 발사
```

---

### 자주 쓰는 Vector3 연산

#### 두 지점 사이의 거리
```gdscript
var dist = player.global_position.distance_to(enemy.global_position)
if dist < 5.0:
    print("가까이 있다!")
```

#### 방향 벡터 구하기 (A에서 B를 향하는 방향)
```gdscript
# enemy에서 player를 향하는 방향
var direction = (player.global_position - global_position).normalized()
velocity = direction * speed
```

```
방향 = (목표 위치) - (현재 위치)
     = Vector3(5, 0, 3) - Vector3(1, 0, 1)
     = Vector3(4, 0, 2)
     → normalized() → Vector3(0.89, 0, 0.45)  (크기 1인 방향 벡터)
```

#### lerp — 두 값 사이를 부드럽게 보간
```gdscript
# weight: 0.0이면 시작값, 1.0이면 끝값, 0.5면 중간
var result = start.lerp(end, weight)

# 카메라가 목표 위치로 부드럽게 따라가기
camera_pos = camera_pos.lerp(target_pos, 5.0 * delta)
# 매 프레임 현재 위치에서 목표까지 5*delta만큼 이동 → 자연스러운 추적
```

#### dot — 두 벡터가 얼마나 같은 방향인지 (내적)
```gdscript
# -1.0: 완전히 반대 방향
#  0.0: 90도 (수직)
# +1.0: 완전히 같은 방향
var d = vec_a.dot(vec_b)

# 사용 예: 적이 플레이어의 시야 안에 있는지 확인
var forward = -global_transform.basis.z  # 적의 앞 방향
var to_player = (player.global_position - global_position).normalized()
var d = forward.dot(to_player)
if d > 0.7:   # cos(45°) ≈ 0.7 → 45도 이내에 있음
    print("플레이어가 시야 안에 있다!")
```

---

### Basis — 회전 정보를 담은 행렬

`global_transform.basis`는 노드의 **로컬 축 방향**을 나타낸다.

```gdscript
global_transform.basis.x  # 노드의 로컬 X축 방향 (오른쪽)
global_transform.basis.y  # 노드의 로컬 Y축 방향 (위)
global_transform.basis.z  # 노드의 로컬 Z축 방향 (뒤) ← -z가 앞
```

**왜 -z가 앞인가?**
Godot의 기본 "앞" 방향이 -Z이기 때문.
따라서 노드가 어느 방향을 바라보든, `-global_transform.basis.z`가 "바라보는 방향"이다.

```gdscript
# 노드가 바라보는 방향 (앞 방향)
var forward = -global_transform.basis.z
# 노드의 오른쪽 방향
var right = global_transform.basis.x

# 카메라 방향으로 이동할 때 자주 쓰는 패턴
var cam_forward = -$CameraPivot.global_transform.basis.z
cam_forward.y = 0.0               # 수평만 (경사면에서 뜨지 않게)
cam_forward = cam_forward.normalized()
```

---

### look_at — 특정 방향을 바라보게 하기

```gdscript
# target 위치를 바라보도록 회전 (Y축 기준 회전)
look_at(target.global_position)

# 수평으로만 바라보게 (적이 플레이어를 향해 회전할 때)
var look_pos = player.global_position
look_pos.y = global_position.y   # Y를 같게 해서 수평으로만 회전
look_at(look_pos)
```

---

## 실습

### 실습 5-1: 좌표 시각적 확인
Claude에게 다음 요청:

> "Godot 4에서 3D 좌표계를 시각적으로 확인하는 씬을 만들어줘.
> `res://scenes/coordinate_test.tscn`으로 저장해줘.
> - 원점에 흰색 구 (반지름 0.2)
> - X=3에 빨간 구, Y=3에 초록 구, Z=3에 파란 구 (각각 반지름 0.3)
> - Camera3D는 (5, 5, 8) 위치에서 원점을 바라보게 설정
> - 파일 직접 작성해줘."

실행 후 어떤 방향이 X(빨강), Y(초록), Z(파랑)인지 눈으로 확인한다.

### 실습 5-2: 코드로 오브젝트 이동
Claude에게 다음 요청:

> "실습 5-1의 빨간 구에 스크립트를 붙여줘.
> - X축으로 초당 2유닛 이동
> - X=6에 도달하면 X=0으로 순간이동
> - `res://scripts/moving_sphere.gd` 직접 작성해줘."

### 실습 5-3: 두 오브젝트 사이 거리 계산
Claude에게 다음 요청:

> "coordinate_test.tscn에서 흰색 구가 파란 구와의 거리를 매 프레임 print()로 출력하게 해줘.
> 흰색 구가 X축으로 이동하면서 거리가 변하는 것을 확인한다."

---

## 확인 포인트
- [ ] Godot에서 Y가 위쪽, Z가 앞쪽(화면 밖, 실제로는 -Z가 앞)인 것을 안다
- [ ] `position`(로컬)과 `global_position`(전역)의 차이를 안다
- [ ] `normalized()`가 왜 이동 코드에 필요한지 안다 (대각선 버그 방지)
- [ ] `distance_to()`로 두 오브젝트 사이 거리를 구할 수 있다
- [ ] 방향 벡터를 구하는 공식(`(목표 - 현재).normalized()`)을 안다
- [ ] `dot()`이 두 벡터의 방향 유사도를 -1~1로 나타내는 것을 안다

## 다음 챕터
[Ch06 — 카메라와 조명](./ch06_camera_and_lighting.md)
