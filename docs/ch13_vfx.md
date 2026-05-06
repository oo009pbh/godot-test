# Ch13 — 파티클 & VFX

> 게임에 생동감을 더하는 파티클 효과, 애니메이션, 화면 연출을 이해한다.
> 폭발, 불꽃, 반짝임, 데미지 효과 — 이것들이 게임을 살아있게 만든다.

---

## 개념

### GPUParticles3D — 파티클 시스템

**비유: 분수**
분수는 물방울(파티클) 수백 개를 동시에 만들어내고,
각 물방울은 자기만의 방향과 속도로 날아가다 사라진다.
GPUParticles3D가 바로 이런 분수 역할을 한다.

**왜 GPU인가?**
파티클 수백 개의 위치를 매 프레임 계산하는 것은 연산이 많다.
GPU는 이런 병렬 연산에 특화되어 있어서 CPU보다 훨씬 빠르다.

| 속성 | 설명 | 기본값 |
|------|------|--------|
| `emitting` | 파티클 방출 켜기/끄기 | true |
| `amount` | 동시에 존재하는 파티클 수 | 8 |
| `lifetime` | 파티클 하나의 수명 (초) | 1.0 |
| `one_shot` | true면 한 번만 방출 후 멈춤 | false |
| `explosiveness` | 한꺼번에 방출되는 비율 (1.0 = 폭발) | 0.0 |
| `process_material` | 파티클 동작을 결정하는 Material | 없음 |

**ProcessMaterial 주요 속성 (Inspector에서 설정):**
```
Direction    → 방출 방향 벡터 (예: (0,1,0) = 위로)
Spread       → 퍼지는 각도 (0도=직선, 180도=구형 전방향)
Gravity      → 파티클에 가해지는 중력
Initial Velocity Min/Max → 초기 속도 범위 (랜덤)
Scale Min/Max → 파티클 크기 범위
Color        → 단색 또는 Gradient (수명에 따라 색 변화)
```

---

### 파티클 종류별 설정

**폭발 효과 (one_shot):**
```gdscript
@onready var particles: GPUParticles3D = $GPUParticles3D

func explode() -> void:
    particles.one_shot = true      # 한 번만
    particles.explosiveness = 1.0  # 모두 한꺼번에 방출
    particles.emitting = true
    # 파티클이 끝난 후 자동 제거
    await get_tree().create_timer(particles.lifetime + 0.1).timeout
    queue_free()
```

**지속 효과 (연기, 불꽃):**
```gdscript
func start_fire() -> void:
    particles.one_shot = false      # 계속 방출
    particles.explosiveness = 0.0
    particles.emitting = true

func extinguish() -> void:
    particles.emitting = false      # 방출 중단 (이미 나간 파티클은 수명대로 사라짐)
```

**코드로 파티클 위치에 생성:**
```gdscript
# explosion.tscn을 미리 만들어두고 필요할 때 인스턴스 생성
@export var explosion_scene: PackedScene

func spawn_explosion(at_position: Vector3) -> void:
    var explosion = explosion_scene.instantiate()
    get_tree().current_scene.add_child(explosion)
    explosion.global_position = at_position
    # explosion.gd에서 파티클 끝나면 자동 queue_free() 처리
```

---

### AnimationPlayer — 키프레임 애니메이션

Inspector에서 노드 속성을 **시간에 따라** 변화시키는 시스템.

**비유: 영화 편집**
영화에서 0초에 문이 닫혀있고, 2초에 완전히 열린다면,
중간 과정은 자동으로 채워진다. AnimationPlayer가 바로 이 방식으로 작동한다.

**만들 수 있는 것:**
- 문 열리는 애니메이션 (rotation 키프레임)
- 코인 회전 + 부유 (rotation.y 증가 + position.y 사인 곡선)
- 아이템 등장 팝업 (scale: `0 → 1.2 → 1.0`)
- 데미지 받을 때 빨개짐 (MeshInstance3D material albedo_color 변화)
- 문이 열릴 때 삐걱이는 소리 타이밍 (AudioStreamPlayer.play() 호출)

```gdscript
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    # 애니메이션 완료 Signal 연결
    anim.animation_finished.connect(_on_animation_finished)

func open_door() -> void:
    anim.play("open")          # "open" 애니메이션 재생

func close_door() -> void:
    anim.play_backwards("open")  # 역재생으로 닫기

func _on_animation_finished(anim_name: StringName) -> void:
    if anim_name == "attack":
        # 공격 애니메이션 끝나면 idle로 전환
        anim.play("idle")

# 현재 애니메이션 확인
if anim.current_animation == "walk":
    anim.play("run")
```

---

### Tween — 코드에서 간단한 애니메이션

AnimationPlayer는 에디터에서 키프레임을 일일이 설정해야 한다.
Tween은 **코드 몇 줄**로 같은 효과를 낸다.

**언제 AnimationPlayer, 언제 Tween?**
- **AnimationPlayer**: 복잡한 애니메이션, 여러 속성 동시 변화, 에디터에서 미리 확인 필요
- **Tween**: 간단한 이동/페이드, 런타임에 동적으로 생성, 매개변수가 자주 바뀜

```gdscript
# 기본 Tween — 2초 동안 Y위치를 1만큼 올림
var tween = create_tween()
tween.tween_property(self, "position:y", position.y + 1.0, 2.0)

# 순차 실행 (올라갔다가 내려오기)
tween.tween_property(self, "position:y", position.y + 1.0, 1.0)
tween.tween_property(self, "position:y", position.y, 1.0)

# 병렬 실행 (동시에 여러 속성 변화)
tween.tween_property(self, "position:y", position.y + 1.0, 1.0)
tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)  # 올라가면서 동시에 투명해짐

# 이징 함수 (움직임에 가속/감속 느낌 추가)
tween.set_trans(Tween.TRANS_BOUNCE)   # 튀기는 느낌
tween.set_trans(Tween.TRANS_ELASTIC)  # 탄성 느낌
tween.set_ease(Tween.EASE_OUT)        # 끝에서 감속

# 무한 반복
tween.set_loops()  # 루프

# Tween 완료 대기
await tween.finished
queue_free()  # 트윈 끝나면 제거
```

**이징 함수 직관적 이해:**
```
EASE_IN:  천천히 시작 → 빠르게 끝
EASE_OUT: 빠르게 시작 → 천천히 끝 (가장 자연스럽게 느껴짐)
EASE_IN_OUT: 천천히 시작 → 빠르게 중간 → 천천히 끝
```

---

### 유용한 VFX 패턴

**피격 효과 (잠깐 빨개졌다 원래 색으로):**
```gdscript
@onready var mesh: MeshInstance3D = $MeshInstance3D

func flash_red() -> void:
    # 원래 material을 저장
    var original_color = mesh.get_active_material(0).albedo_color

    mesh.get_active_material(0).albedo_color = Color.RED

    var tween = create_tween()
    tween.tween_property(
        mesh.get_active_material(0), "albedo_color",
        original_color, 0.15
    )
```

**카메라 흔들림 (피격 시 임팩트 느낌):**
```gdscript
# camera.gd에 추가
func shake(intensity: float = 0.3, duration: float = 0.2) -> void:
    var original_offset = h_offset
    var elapsed = 0.0
    while elapsed < duration:
        h_offset = original_offset + randf_range(-intensity, intensity)
        v_offset = randf_range(-intensity, intensity)
        elapsed += get_process_delta_time()
        await get_tree().process_frame
    h_offset = original_offset
    v_offset = 0.0
```

**아이템 수집 효과 (올라가며 사라지기):**
```gdscript
func collect() -> void:
    # 물리 끄기 (더 이상 충돌하지 않게)
    $CollisionShape3D.disabled = true

    var tween = create_tween()
    tween.tween_property(self, "position:y", position.y + 1.5, 0.5)
    tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
    tween.parallel().tween_property(self, "scale", Vector3(1.5, 1.5, 1.5), 0.5)
    await tween.finished
    queue_free()
```

---

### GPUParticles3D vs CPUParticles3D

| 구분 | GPUParticles3D | CPUParticles3D |
|------|----------------|----------------|
| 성능 | 더 빠름 (GPU 처리) | 더 느림 |
| 호환성 | 고성능 GPU 필요 | 모든 기기 |
| Web/모바일 | 일부 지원 안 됨 | 광범위 지원 |

Web 빌드나 저사양 기기가 목표라면 `CPUParticles3D` 사용.
사용법은 거의 동일하다.

---

## 실습

### 실습 13-1: 적 처치 폭발 효과
Claude에게 다음 요청:

> "Godot 4에서 적이 죽을 때 나타나는 폭발 파티클 효과를 만들어줘.
> - `res://scenes/effects/explosion.tscn`, `res://scripts/explosion.gd`
> - GPUParticles3D, one_shot = true, explosiveness = 1.0
> - 빨간/주황 색상 Gradient (수명 초반은 밝은 주황, 후반은 빨간색으로 어두워짐)
> - Spread: 180도 (구형으로 퍼짐), 파티클 수: 30개, 수명: 0.5초
> - 파티클 종료 후 자동 queue_free()
> - game_manager.gd에 spawn_explosion(at_position: Vector3) 유틸 함수 추가
> - enemy.gd에서 죽을 때 GameManager.spawn_explosion(global_position) 호출"

### 실습 13-2: 코인 반짝임 애니메이션
Claude에게 다음 요청:

> "Godot 4에서 둥둥 떠다니며 회전하는 코인 아이템을 만들어줘.
> - `res://scenes/items/coin.tscn`, `res://scripts/coin.gd`
> - MeshInstance3D: CylinderMesh (radius 0.3, height 0.1), 금색 StandardMaterial3D
> - AnimationPlayer로: Y축 계속 회전 (360도 / 2초) + 위아래 부유 (position.y ±0.2, 사인 곡선)
> - Area3D: 플레이어 body_entered Signal
> - 플레이어 접촉 시 Tween 수집 효과 (위로 올라가며 투명해짐, 0.4초) 후 queue_free()
> - GameManager.add_score(10) 호출
> - 'coin' 그룹에 추가해서 GameManager에서 총 코인 수 추적 가능하게"

### 실습 13-3: 피격 & 카메라 흔들림
Claude에게 다음 요청:

> "플레이어가 데미지를 받을 때 시각적 피드백을 추가해줘.
> - 피격 시 0.15초 동안 플레이어 메시가 빨간색으로 변했다가 원래 색으로 돌아옴
> - Camera3D가 피격 방향으로 0.2초간 흔들림 (intensity 0.3)
> - 화면 가장자리가 잠깐 빨갛게 되는 비네트 효과 (ColorRect, Full Rect, 빨간색 alpha 0→0.4→0)
> - player.gd의 take_damage() 함수에 통합"

---

## 확인 포인트
- [ ] `one_shot = true`와 지속 파티클의 차이를 안다
- [ ] `explosiveness`가 파티클을 동시에 방출하는 비율임을 안다
- [ ] AnimationPlayer와 Tween의 사용 케이스 차이를 안다 (에디터 vs 코드)
- [ ] `EASE_OUT`이 가장 자연스럽게 느껴지는 이유를 안다 (빠른 시작, 느린 끝)
- [ ] `tween.parallel()`로 여러 속성을 동시에 변화시킬 수 있다
- [ ] `await tween.finished`로 트윈이 끝날 때까지 기다릴 수 있다
- [ ] `queue_free()`가 노드를 씬에서 안전하게 제거하는 것임을 안다

## 다음 챕터
[Ch14 — 오디오](./ch14_audio.md)
