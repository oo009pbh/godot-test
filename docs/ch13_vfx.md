# Ch13 — 파티클 & VFX

---

## 개념

### GPUParticles3D
GPU에서 처리하는 고성능 파티클 시스템.

| 속성 | 설명 |
|------|------|
| `emitting` | 파티클 방출 켜기/끄기 |
| `amount` | 동시에 존재하는 파티클 수 |
| `lifetime` | 파티클 하나의 수명 (초) |
| `one_shot` | true면 한 번만 방출 후 멈춤 |
| `explosiveness` | 한꺼번에 방출되는 비율 (폭발 효과) |
| `process_material` | 파티클 동작을 결정하는 Material |

**ProcessMaterial 주요 속성:**
```
Direction: 방출 방향 벡터
Spread: 퍼지는 각도 (0 = 직선, 180 = 구형)
Gravity: 중력 영향
Initial Velocity: 초기 속도
Scale: 파티클 크기
Color: 색상 (Gradient로 수명에 따라 변화 가능)
```

### 코드에서 파티클 제어

```gdscript
@onready var particles = $GPUParticles3D

# 폭발 효과 (one_shot = true)
func explode():
    particles.one_shot = true
    particles.emitting = true

# 지속 방출 (연기, 불꽃)
func start_smoke():
    particles.one_shot = false
    particles.emitting = true

func stop_smoke():
    particles.emitting = false
```

### AnimationPlayer
노드의 모든 속성을 시간에 따라 변화시키는 애니메이션 시스템.

```gdscript
@onready var anim = $AnimationPlayer

# 재생
anim.play("walk")
anim.play("attack")

# 정지
anim.stop()

# 현재 애니메이션 이름 확인
anim.current_animation

# 애니메이션 완료 Signal
anim.animation_finished.connect(_on_animation_finished)
```

**AnimationPlayer로 만들 수 있는 것:**
- 문 열리는 애니메이션 (rotation 키프레임)
- 코인 회전 (rotation.y가 계속 증가)
- 아이템 등장 팝업 (scale 0 → 1)
- 데미지 받을 때 빨개짐 (material albedo_color 변화)

### Tween — 코드에서 간단한 애니메이션
AnimationPlayer보다 간단하게 코드로 애니메이션:

```gdscript
# 2초 동안 Y위치를 1 올림
var tween = create_tween()
tween.tween_property(self, "position:y", position.y + 1.0, 2.0)

# 연속 트윈
tween.tween_property(self, "position:y", position.y, 2.0)  # 다시 내려옴

# 이징 함수 적용
tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
```

---

## 실습

### 실습 13-1: 적 처치 폭발 효과
Claude에게 다음 요청:

> "Godot 4에서 적이 죽을 때 나타나는 폭발 파티클 효과를 만들어줘.
> - `res://scenes/effects/explosion.tscn`
> - GPUParticles3D, one_shot = true
> - 빨간/주황 구형 파티클, 빠르게 퍼지다 사라짐
> - 약 0.3초 안에 모두 방출
> - 파티클 종료 후 자동으로 씬에서 제거 (queue_free)
> - 코드에서 spawn_explosion(position) 함수로 호출할 수 있게 GameManager에 유틸 함수 추가"

### 실습 13-2: 코인 반짝임 애니메이션
Claude에게 다음 요청:

> "Godot 4에서 둥둥 떠다니며 회전하는 코인 아이템을 만들어줘.
> - `res://scenes/items/coin.tscn`
> - MeshInstance3D (CylinderMesh, 납작하게)
> - AnimationPlayer로: 계속 Y축 회전 + 위아래로 부드럽게 떠다님
> - 플레이어가 닿으면 (Area3D) 반짝 빛나는 Tween 후 사라짐
> - GameManager.add_score(10) 호출"

---

## 확인 포인트
- [ ] `one_shot`과 지속 파티클의 차이를 안다
- [ ] AnimationPlayer와 Tween의 사용 케이스 차이를 안다
- [ ] `queue_free()`가 노드를 씬에서 제거하는 것임을 안다

## 다음 챕터
[Ch14 — 오디오](./ch14_audio.md)
