# Ch06 — 카메라와 조명

---

## 개념

### Camera3D

| 속성 | 설명 | 기본값 |
|------|------|--------|
| `fov` | 시야각 (Field of View). 클수록 넓게 보임 | 75 |
| `near` | 이 거리 이하는 안 보임 | 0.05 |
| `far` | 이 거리 이상은 안 보임 | 4000 |
| `projection` | Perspective(원근감 있음) / Orthogonal(평행투영) | Perspective |

**3인칭 카메라 패턴:**
```
Player (CharacterBody3D)
└── CameraPivot (Node3D)      ← 회전 축
    └── SpringArm3D           ← 벽에 닿으면 자동으로 카메라 당김
        └── Camera3D          ← 실제 카메라
```

**SpringArm3D**: 카메라와 플레이어 사이에 벽이 있으면 카메라를 자동으로 앞으로 당겨준다. 3인칭 게임에 필수.

### 조명 종류

| 조명 | 특징 | 용도 |
|------|------|------|
| `DirectionalLight3D` | 태양처럼 전체에 방향이 있는 조명 | 야외, 주 조명 |
| `OmniLight3D` | 전구처럼 구형으로 퍼지는 조명 | 램프, 횃불 |
| `SpotLight3D` | 손전등처럼 원뿔 형태 조명 | 스포트라이트, 헤드라이트 |

**DirectionalLight3D 주요 속성:**
- `energy`: 밝기 (1.0 = 기본)
- `shadow_enabled`: 그림자 활성화
- `rotation_degrees`: 조명 방향 (x를 -45 ~ -60 정도로 설정이 자연스러움)

### WorldEnvironment
하늘(Sky), 안개(Fog), 전체적인 밝기(Ambient Light)를 설정하는 Node.

```
WorldEnvironment
    └── Environment 리소스
        ├── Background: Sky / Color / HDRI
        ├── Ambient Light: 그림자가 지는 면의 밝기
        ├── Fog: 멀리 있는 오브젝트에 안개 효과
        └── Glow: 밝은 부분 빛 번짐
```

### 카메라 보간 (Lerp)
딱딱하게 따라오는 카메라 → 부드럽게 따라오는 카메라:

```gdscript
func _process(delta):
    # weight가 작을수록 더 천천히 따라옴 (0.0 ~ 1.0)
    global_position = global_position.lerp(target_position, 5.0 * delta)
```

---

## 실습

### 실습 6-1: 3인칭 카메라 Rig
Claude에게 다음 요청:

> "Godot 4에서 3인칭 카메라 Rig를 만들어줘.
> Player(CharacterBody3D) 아래에 CameraPivot(Node3D) > SpringArm3D > Camera3D 구조로 만들어줘.
> - SpringArm length: 4
> - Camera position: (0, 0.5, 0)
> - 마우스 우클릭 드래그로 카메라가 플레이어 주위를 회전하게 해줘
> - 마우스 입력은 project.godot InputMap에 'camera_rotate'로 추가해줘
> `res://scenes/player.tscn`과 `res://scripts/player.gd`로 만들어줘."

### 실습 6-2: 조명 분위기 실험
Claude에게 다음 요청:

> "현재 씬에 저녁 분위기를 만들어줘.
> DirectionalLight3D의 색상을 주황빛으로, energy를 0.8로 설정하고
> WorldEnvironment에 약간의 Fog를 추가해줘.
> Sky는 주황-보라 그라디언트 색상으로 설정해줘."

---

## 확인 포인트
- [ ] SpringArm3D가 왜 3인칭 카메라에 필요한지 안다
- [ ] DirectionalLight3D와 OmniLight3D의 차이를 안다
- [ ] WorldEnvironment가 무엇을 담당하는지 안다
- [ ] lerp가 카메라 부드러움에 어떻게 사용되는지 안다

## 다음 챕터
[Ch07 — 3D 물리 & 충돌](./ch07_3d_physics.md)
