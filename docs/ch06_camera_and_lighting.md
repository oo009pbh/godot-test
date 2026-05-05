# Ch06 — 카메라와 조명

---

## 개념

### Camera3D

Godot에서 화면에 뭔가를 보여주려면 반드시 **활성화된 Camera3D 노드**가 씬 안에 있어야 한다.
Camera3D는 "이 위치에서 이 방향으로 찍은 화면을 출력해"라는 뷰포트 지시자다.

| 속성 | 설명 | 기본값 |
|------|------|--------|
| `fov` | Field of View. 시야각. 클수록 주변이 넓게 보이고 원근 왜곡이 커짐 | 75 |
| `near` | 카메라에서 이 거리보다 가까운 오브젝트는 렌더링 안 됨 | 0.05 |
| `far` | 카메라에서 이 거리보다 먼 오브젝트는 렌더링 안 됨 | 4000 |
| `projection` | Perspective(원근감 있음) / Orthogonal(평행 투영, 원근 없음) | Perspective |

**Perspective vs Orthogonal:**
- Perspective: 멀리 있는 것이 작아 보임. 3D 게임 대부분.
- Orthogonal: 멀리 있어도 크기가 같음. 2D처럼 보이는 전략 게임, 퍼즐 게임.

---

### 3인칭 카메라 Rig 구조

단순히 `CharacterBody3D` 밑에 `Camera3D`만 놓으면 카메라가 플레이어와 함께 이동하지만 **회전이 어렵고 벽에 카메라가 묻힌다**. 그래서 3인칭 게임에서는 아래 구조를 쓴다:

```
Player (CharacterBody3D)
└── CameraPivot (Node3D)      ← 회전 축
    └── SpringArm3D           ← 충돌 감지 + 길이 조절
        └── Camera3D          ← 실제 카메라
```

#### CameraPivot (Node3D)

- **역할**: 카메라 회전의 기준점(피벗).
- 플레이어 위 `(0, 1.0, 0)` 위치에 놓아서 카메라가 머리 근처를 중심으로 돈다.
- `rotation.y`를 바꾸면 카메라가 플레이어 주변을 **수평 회전**.
- `rotation.x`를 바꾸면 카메라가 **위아래 각도** 변경.
- 플레이어 몸 자체를 회전시키지 않아도 되기 때문에, 이동 방향과 카메라 방향을 독립적으로 제어할 수 있다.

#### SpringArm3D

- **역할**: 카메라와 플레이어 사이에 벽이나 지형이 끼어들면, 카메라를 자동으로 앞으로 당겨준다.
- `spring_length = 4.0` → 카메라가 최대 4유닛 뒤에 위치. 벽이 가까우면 자동으로 줄어듦.
- SpringArm3D 자체는 카메라를 끝에 매달아두는 **보이지 않는 팔** 같은 존재.
- 내부적으로 피벗에서 팔 방향으로 레이캐스트를 쏘고, 충돌 지점까지만 팔을 줄인다.

```
[벽이 없을 때]
Player ←——4유닛——→ Camera

[벽이 있을 때]
Player ←—2유닛—→ Wall  Camera (자동으로 앞으로 이동)
```

#### Camera3D 위치

- SpringArm3D의 자식으로 놓이면 팔 끝에 위치한다.
- `transform = Transform3D(1,0,0, 0,1,0, 0,0,1, 0, 0.5, 0)` → 팔 끝에서 약간 위(0.5)로 올려서 자연스러운 시점.

---

### 카메라 상대 이동 (Camera-relative Movement)

3인칭 게임에서 "위 방향키 = 앞으로 이동"이 되려면, **카메라가 바라보는 방향 기준으로 이동**해야 한다.

```gdscript
# CameraPivot의 글로벌 기저(basis)에서 방향 추출
var forward: Vector3 = -$CameraPivot.global_transform.basis.z  # 카메라 앞
var right: Vector3 = $CameraPivot.global_transform.basis.x     # 카메라 오른쪽

# Y 성분 제거 → 경사면이어도 수평으로만 이동
forward.y = 0.0
right.y = 0.0
forward = forward.normalized()
right = right.normalized()
```

**왜 `.basis.z`가 앞 방향인가?**
- Godot 3D에서 기본 **앞 방향은 -Z 축**.
- `basis.z`는 로컬 Z축이 글로벌 공간에서 어느 방향인지를 나타냄.
- 따라서 `-basis.z`가 실제 "앞을 향하는" 벡터.

**왜 Y를 0으로 만드는가?**
- 카메라가 아래를 내려다보고 있으면 `basis.z`의 Y 성분이 생긴다.
- 그대로 쓰면 "앞으로 가" 했을 때 공중으로 뜨거나 땅속으로 파고든다.
- Y를 제거하고 normalize해서 항상 XZ 평면에서만 이동.

---

### 조명 종류

| 조명 | 특징 | 용도 |
|------|------|------|
| `DirectionalLight3D` | 태양처럼 전체에 방향이 있는 조명. 위치 무관, 방향만 영향 | 야외, 주 조명 |
| `OmniLight3D` | 전구처럼 구형으로 퍼지는 조명. 거리에 따라 감쇠 | 램프, 횃불, 마법 오라 |
| `SpotLight3D` | 손전등처럼 원뿔 형태 조명. 방향과 각도 지정 | 스포트라이트, 헤드라이트 |

**DirectionalLight3D 주요 속성:**
- `energy`: 밝기 (1.0 = 기본)
- `shadow_enabled`: 그림자 활성화
- `rotation_degrees`: 조명 방향. x를 -45 ~ -60° 정도로 하면 자연스러운 태양.
- `light_color`: 색상. 주황빛이면 저녁 느낌.

---

### WorldEnvironment

하늘(Sky), 안개(Fog), 전체 밝기(Ambient Light)를 설정하는 노드.
`Environment` 리소스를 들고 있고, 씬 전체에 적용된다.

```
WorldEnvironment
    └── Environment 리소스
        ├── Background : Sky(하늘 색/텍스처) / Color(단색) / HDRI
        ├── Ambient Light : 그림자진 면의 밝기 (너무 낮으면 완전 검정)
        ├── Fog : 멀리 있는 오브젝트에 안개 효과
        └── Glow : 밝은 부분 빛 번짐 (HDR 효과)
```

**ProceduralSkyMaterial**: 코드로 하늘 색을 지정하는 방식.
- `sky_top_color`: 하늘 꼭대기 색
- `sky_horizon_color`: 수평선 색
- `ground_bottom_color`: 땅 색

---

### 카메라 보간 (Lerp)

딱딱하게 따라오는 카메라 → 부드럽게 따라오는 카메라:

```gdscript
func _process(delta):
    # weight가 작을수록 더 천천히 따라옴 (0.0 ~ 1.0)
    global_position = global_position.lerp(target_position, 5.0 * delta)
```

SpringArm3D를 쓰면 벽 회피는 자동이므로, Lerp는 카메라 lag(살짝 뒤처지는 느낌)을 원할 때 추가로 쓴다.

---

## 실습

### 실습 6-1: 3인칭 카메라 Rig ✅

**Claude에게 한 요청:**
> "Godot 4에서 3인칭 카메라 Rig를 만들어줘.
> Player(CharacterBody3D) 아래에 CameraPivot(Node3D) > SpringArm3D > Camera3D 구조로 만들어줘.
> SpringArm length: 4 / Camera position: (0, 0.5, 0)
> 마우스 우클릭 드래그로 카메라가 플레이어 주위를 회전하게 해줘
> 마우스 입력은 project.godot InputMap에 'camera_rotate'로 추가해줘
> res://scenes/player.tscn과 res://scripts/player.gd로 만들어줘."

**Claude가 실제로 작업한 내용:**

1. **`res://scenes/player.tscn` 생성** — Player 씬을 world.tscn에서 분리해서 독립 씬으로 만들었다.
   - 구조: `Player(CharacterBody3D)` → `MeshInstance3D` + `CollisionShape3D` + `CameraPivot(Node3D)` → `SpringArm3D` → `Camera3D`
   - CameraPivot 위치: `(0, 1.0, 0)` (머리 높이)
   - SpringArm3D: `spring_length = 4.0`
   - Camera3D: `transform` Y=0.5 (팔 끝에서 약간 위)

2. **`res://scripts/player.gd` 수정** — 마우스 입력 + 카메라 상대 이동 추가.
   - `_input(event)` 추가: 마우스 우클릭 드래그 시 `CameraPivot.rotation.y/x` 변경
   - 상하 각도 제한: `-60° ~ +20°` (땅을 뚫어보거나 너무 위를 못 보게)
   - `_physics_process()`: `CameraPivot.global_transform.basis`에서 forward/right 추출 → 카메라 방향 기준 이동

3. **`res://scenes/world.tscn` 수정** — Player를 inline 정의에서 `player.tscn` 인스턴스로 교체.

4. **`project.godot` 수정** — `[input]` 섹션에 `camera_rotate` 액션 추가 (마우스 우클릭, button_index=2).

**조작법:**
- 방향키: 카메라가 바라보는 방향 기준으로 이동
- 스페이스: 점프
- 마우스 우클릭 + 드래그: 카메라 회전

**발생했던 오류와 수정:**
- GDScript가 `$CameraPivot.global_transform.basis.z`의 타입을 추론 못 함
- `:=` (타입 추론) → `: Vector3 =` (명시 선언)으로 수정

---

### 실습 6-2: 조명 분위기 실험

Claude에게 다음 요청:

> "현재 씬에 저녁 분위기를 만들어줘.
> DirectionalLight3D의 색상을 주황빛으로, energy를 0.8로 설정하고
> WorldEnvironment에 약간의 Fog를 추가해줘.
> Sky는 주황-보라 그라디언트 색상으로 설정해줘."

---

## 확인 포인트

- [ ] CameraPivot이 왜 Player의 자식이어야 하는지 안다
- [ ] SpringArm3D가 왜 3인칭 카메라에 필요한지 안다
- [ ] 카메라 방향 기준 이동에서 왜 Y를 0으로 만드는지 안다
- [ ] DirectionalLight3D와 OmniLight3D의 차이를 안다
- [ ] WorldEnvironment가 무엇을 담당하는지 안다

## 다음 챕터
[Ch07 — 3D 물리 & 충돌](./ch07_3d_physics.md)
