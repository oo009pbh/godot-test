# Ch06 — 카메라와 조명

> 카메라는 "눈"이고 조명은 "분위기"다.
> 같은 게임도 카메라와 조명 설정에 따라 완전히 다른 느낌이 된다.

---

## 개념

### Camera3D — Godot의 눈

Godot에서 화면에 뭔가를 보여주려면 반드시 **활성화된 Camera3D 노드**가 씬 안에 있어야 한다.
Camera3D는 "이 위치에서 이 방향으로 찍은 화면을 출력해"라는 뷰포트 지시자다.

**Camera3D 없으면 어떻게 되나?**
게임을 실행하면 화면이 회색이거나 아무것도 보이지 않는다.

#### Camera3D 주요 속성

| 속성 | 설명 | 기본값 | 실용 팁 |
|------|------|--------|---------|
| `fov` | Field of View (시야각). 클수록 넓게 보이지만 왜곡 심해짐 | 75 | 3인칭: 70~80, 1인칭: 90~100 |
| `near` | 이 거리보다 가까운 것은 렌더링 안 됨 | 0.05 | 너무 크면 플레이어 몸 잘림 |
| `far` | 이 거리보다 먼 것은 렌더링 안 됨 | 4000 | 너무 작으면 먼 지형이 사라짐 |
| `projection` | 원근감 방식 | Perspective | 대부분 게임은 Perspective |
| `current` | 이 카메라를 활성 카메라로 사용 | false | 씬에 카메라 여러 개 시 제어 |

**Perspective vs Orthogonal:**
```
Perspective (원근):        Orthogonal (직교):
멀리 있으면 작게 보임      거리와 무관하게 같은 크기
3D 게임의 기본            2D처럼 보이는 전략 게임, 퍼즐
```

---

### 3인칭 카메라 Rig 구조

단순히 `CharacterBody3D` 밑에 `Camera3D`만 놓으면 두 가지 문제가 생긴다:
1. 카메라 회전이 플레이어 몸 회전과 엮여서 이상해짐
2. 벽 뒤로 가면 카메라가 벽 안으로 들어감

그래서 3인칭 게임에서는 아래 4노드 구조를 쓴다:

```
Player (CharacterBody3D)
└── CameraPivot (Node3D)      ← ① 회전 중심점
    └── SpringArm3D           ← ② 벽 감지 + 팔 길이 조절
        └── Camera3D          ← ③ 실제 카메라
```

#### ① CameraPivot (Node3D) — 회전 중심

**역할:** 카메라가 플레이어 주위를 도는 **기준점(피벗)**.

```
위에서 본 모습:

        Camera
           \
            \
             CameraPivot (Player 머리 위)
            /
           /
        Camera (왼쪽으로 90도 회전 시)
```

- 위치를 `(0, 1.0, 0)`으로 설정 → 플레이어 머리 근처가 회전 중심
- `rotation.y` 변경 → 카메라가 플레이어 주변을 **수평 회전**
- `rotation.x` 변경 → 카메라가 **위아래 각도** 변경
- 플레이어 몸(`CharacterBody3D`)은 건드리지 않아도 됨 → 이동 방향과 카메라 방향 독립

#### ② SpringArm3D — 자동 벽 회피 팔

**비유: 셀카봉**
- 셀카봉처럼 카메라를 멀리 밀어냄
- 벽이 있으면 셀카봉을 짧게 줄여서 카메라가 벽 안으로 안 들어감

```
[벽 없을 때]
Player ←──── 4유닛 ────→ Camera

[벽이 있을 때]
Player ←── 2유닛 ──→ Wall  Camera (자동으로 앞으로 당겨짐)
```

**주요 속성:**
| 속성 | 기본값 | 설명 |
|------|--------|------|
| `spring_length` | 1.0 | 팔 최대 길이. 3인칭: 3~5가 일반적 |
| `margin` | 0.01 | 충돌체에서 얼마나 떨어질지 |
| `collision_mask` | 1 | 어떤 물리 레이어와 충돌 감지할지 |

**SpringArm3D가 자기 자신을 막는 버그:**
플레이어 캡슐(CapsuleShape3D)을 SpringArm3D가 장애물로 인식해서
점프/착지 시 카메라가 순간적으로 가까워지는 현상이 생긴다.

```gdscript
func _ready():
    # 플레이어 자신을 SpringArm3D 충돌 제외 목록에 추가
    $CameraPivot/SpringArm3D.add_excluded_object(get_rid())
```

`get_rid()` = 이 노드의 물리 엔진 고유 ID. 이 ID를 제외하면 SpringArm3D가
자기 자신의 충돌체를 무시하게 된다.

#### ③ Camera3D 위치

SpringArm3D의 자식으로 놓으면 팔 끝에 위치한다.
보통 팔 끝에서 `(0, 0.5, 0)` — 약간 위로 올려서 자연스러운 시점을 만든다.

---

### 카메라 상대 이동 (Camera-relative Movement)

3인칭 게임에서 "위 방향키 = 앞으로 이동"이 되려면,
**카메라가 바라보는 방향 기준으로 이동**해야 한다.

**왜 필요한가?**
카메라가 오른쪽을 바라보고 있을 때 "앞으로" 누르면
세계 기준 앞(-Z)이 아니라 카메라가 바라보는 방향으로 이동해야 자연스럽다.

```gdscript
func _get_input_direction() -> Vector3:
    # CameraPivot의 basis에서 방향 추출
    var forward: Vector3 = -$CameraPivot.global_transform.basis.z
    var right: Vector3 = $CameraPivot.global_transform.basis.x

    # Y 성분 제거 → 경사면에서도 수평으로만 이동
    forward.y = 0.0
    right.y = 0.0
    forward = forward.normalized()
    right = right.normalized()

    var direction := Vector3.ZERO
    if Input.is_action_pressed("ui_up"):
        direction += forward
    if Input.is_action_pressed("ui_down"):
        direction -= forward
    if Input.is_action_pressed("ui_right"):
        direction += right
    if Input.is_action_pressed("ui_left"):
        direction -= right

    return direction.normalized()
```

**왜 Y를 0으로 만드는가?**
카메라가 약간 아래를 내려다보고 있으면 `basis.z`의 Y 성분이 생긴다.
그대로 쓰면 "앞으로 가" 했을 때 공중으로 뜨거나 땅 속으로 파고든다.

---

### 마우스로 카메라 회전

```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
            # 마우스 이동량(relative)으로 카메라 피벗 회전
            $CameraPivot.rotation.y -= event.relative.x * mouse_sensitivity
            $CameraPivot.rotation.x -= event.relative.y * mouse_sensitivity

            # 상하 각도 제한 (위를 너무 많이 보거나 땅을 뚫어보지 못하게)
            $CameraPivot.rotation.x = clamp(
                $CameraPivot.rotation.x,
                deg_to_rad(-60),   # 최대 60도 아래
                deg_to_rad(20)     # 최대 20도 위
            )
```

**`event.relative`**: 이전 프레임 대비 마우스가 얼마나 이동했는지 (픽셀).
**`mouse_sensitivity`**: 보통 0.002~0.005 정도가 자연스럽다.

---

### 조명 시스템

#### 조명 종류 비교

| 조명 | 특징 | 용도 |
|------|------|------|
| `DirectionalLight3D` | 태양처럼 전체에 같은 방향. 위치 무관 | 야외, 주 조명 |
| `OmniLight3D` | 전구처럼 구형으로 퍼짐. 거리에 따라 감쇠 | 램프, 횃불, 마법 오라 |
| `SpotLight3D` | 손전등처럼 원뿔 형태. 방향과 각도 지정 | 스포트라이트, 헤드라이트 |

#### DirectionalLight3D 상세 설정

```
DirectionalLight3D
├── Light Color: 색상 (주황빛 → 저녁, 흰빛 → 낮)
├── Light Energy: 밝기 (1.0 = 기본, 0.5 = 어둑어둑)
├── Shadow
│   ├── Enabled: true/false (그림자 켜기)
│   └── Shadow Mode: PCF13 (부드러운 그림자)
└── Transform
    └── Rotation: x=-45, y=-30 → 자연스러운 태양 각도
```

**시간대별 설정 예:**
```
낮 (정오): color=흰색, energy=1.2, rotation.x=-60
저녁: color=주황(1.0, 0.5, 0.1), energy=0.8, rotation.x=-15
밤: energy=0.1~0 + OmniLight3D로 달빛 효과
```

#### OmniLight3D 주요 속성

```gdscript
# 코드에서 OmniLight3D 조절
var light = $OmniLight3D
light.light_color = Color(1.0, 0.5, 0.0)   # 주황빛
light.light_energy = 2.0                    # 밝기 2배
light.omni_range = 8.0                      # 8유닛 반경
light.shadow_enabled = true
```

---

### WorldEnvironment — 전체 분위기 설정

씬 전체의 배경, 안개, 전반적인 빛 분위기를 결정하는 노드.
씬에 하나만 있으면 된다.

```
WorldEnvironment
    └── Environment 리소스
        ├── Background (배경)
        │   ├── Mode: Sky(하늘), Color(단색), HDRI(파노라마 이미지)
        │   └── Sky Material
        ├── Ambient Light (그림자진 면의 기본 밝기)
        │   └── Energy: 0.3~0.5 (너무 낮으면 그림자가 완전 검정)
        ├── Fog (안개)
        │   ├── Enabled: true
        │   ├── Density: 0.005~0.01 (짙을수록 안개가 가까이 시작)
        │   └── Color: 회색/흰색이 자연스러움
        ├── Glow (빛 번짐)
        │   ├── Enabled: true
        │   └── Intensity: 0.5~1.5 (밝은 부분에 빛 번짐 효과)
        └── SSAO (환경광 차폐, 틈새가 어둡게)
```

**ProceduralSkyMaterial — 코드로 하늘 만들기:**
```
sky_top_color: 하늘 꼭대기 색
sky_horizon_color: 수평선 색 (보통 밝은 색)
ground_bottom_color: 땅 반사색
```

```gdscript
# 저녁 하늘 설정 예
sky_material.sky_top_color = Color(0.1, 0.1, 0.4)       # 진한 파랑
sky_material.sky_horizon_color = Color(1.0, 0.4, 0.1)   # 주황
sky_material.ground_bottom_color = Color(0.2, 0.1, 0.0) # 어두운 갈색
```

---

### 카메라 보간 (Lerp)

카메라가 딱딱하게 순간이동하는 것을 부드럽게 만드는 기법:

```gdscript
# 방법 1: 위치 lerp (살짝 뒤처지는 카메라 lag 효과)
func _process(delta: float) -> void:
    global_position = global_position.lerp(target_position, 5.0 * delta)
    # weight가 클수록 빠르게 따라옴 (5.0 = 빠름, 1.0 = 느림)

# 방법 2: SpringArm3D 쓰면 벽 회피 자동 + Lerp는 추가로
# SpringArm3D 자체는 이미 부드럽게 줄어드는 애니메이션이 있다
```

**Lerp 수식 이해:**
```
매 프레임: 현재위치 = 현재위치 + (목표위치 - 현재위치) × weight
        = 현재위치 × (1 - weight) + 목표위치 × weight

즉, weight = 0.1이면 매 프레임 남은 거리의 10%만 이동
→ 목표에 가까워질수록 속도가 줄어듦 (지수적 감소)
```

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
   - Camera3D: Y=0.5 (팔 끝에서 약간 위)

2. **`res://scripts/player.gd` 수정** — 마우스 입력 + 카메라 상대 이동 추가.
   - `_input(event)` 추가: 마우스 우클릭 드래그 시 `CameraPivot.rotation.y/x` 변경
   - 상하 각도 제한: `-60° ~ +20°`
   - `_physics_process()`: `CameraPivot.global_transform.basis`에서 forward/right 추출 → 카메라 방향 기준 이동

3. **`res://scenes/world.tscn` 수정** — Player를 `player.tscn` 인스턴스로 교체.

4. **`project.godot` 수정** — `[input]` 섹션에 `camera_rotate` 액션 추가.

**조작법:**
- 방향키: 카메라가 바라보는 방향 기준으로 이동
- 스페이스: 점프
- 마우스 우클릭 + 드래그: 카메라 회전

**발생했던 오류와 수정:**
- GDScript가 `$CameraPivot.global_transform.basis.z`의 타입을 추론 못 함
- `:=` (타입 추론) → `: Vector3 =` (명시 선언)으로 수정

---

### 실습 6-2: 조명 분위기 실험 ✅

Claude에게 다음 요청:

> "현재 씬에 저녁 분위기를 만들어줘.
> DirectionalLight3D의 색상을 주황빛으로, energy를 0.8로 설정하고
> WorldEnvironment에 약간의 Fog를 추가해줘.
> Sky는 주황-보라 그라디언트 색상으로 설정해줘."

---

### 실습 6-3: 카메라 SpringArm3D 버그 수정

실습 6-1 이후 점프/착지 시 카메라가 순간적으로 가까워지는 버그가 있다면:

Claude에게 다음 요청:
> "player.gd에 _ready() 함수를 추가해서 SpringArm3D가 플레이어 자신의
> CapsuleShape3D를 충돌로 인식하지 않도록 제외 처리해줘.
> add_excluded_object(get_rid()) 사용."

---

## 확인 포인트
- [ ] Camera3D가 없으면 게임 화면에 아무것도 안 보이는 이유를 안다
- [ ] CameraPivot이 왜 Player의 자식이어야 하는지 안다 (같이 이동하기 위해)
- [ ] SpringArm3D가 왜 3인칭 카메라에 필요한지 안다 (벽 관통 방지)
- [ ] SpringArm3D의 자기 자신 충돌 버그와 해결법을 안다 (add_excluded_object)
- [ ] 카메라 방향 기준 이동에서 왜 Y를 0으로 만드는지 안다 (경사면 이동 방지)
- [ ] DirectionalLight3D, OmniLight3D, SpotLight3D의 차이를 안다
- [ ] WorldEnvironment가 Sky, Fog, Glow, Ambient Light를 담당하는 것을 안다
- [ ] lerp()가 부드러운 카메라 추적에 왜 적합한지 안다

## 다음 챕터
[Ch07 — 3D 물리 & 충돌](./ch07_3d_physics.md)
