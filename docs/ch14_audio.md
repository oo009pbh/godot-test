# Ch14 — 오디오

> 효과음과 배경음악이 게임에 생동감을 더한다.
> Godot의 오디오 시스템은 간단하지만, 몇 가지 중요한 개념을 이해해야 제대로 쓸 수 있다.

---

## 개념

### 오디오 노드 종류

| 노드 | 용도 | 실용 예 |
|------|------|---------|
| `AudioStreamPlayer` | 위치 없는 2D 오디오 | BGM, UI 클릭음, 승리 팡파레 |
| `AudioStreamPlayer2D` | 2D 공간 오디오 | 2D 게임의 발소리, 폭발음 |
| `AudioStreamPlayer3D` | 3D 공간 오디오 (거리 감쇠) | 발소리, 폭발, NPC 대사 |

**언제 어느 것을?**
- BGM처럼 "어디서 나오는지 위치가 없는" 소리 → `AudioStreamPlayer`
- 적이 폭발할 때처럼 "특정 위치에서 나오는" 소리 → `AudioStreamPlayer3D`

**비유:**
- `AudioStreamPlayer` = 헤드폰으로 음악 듣기 (방향/거리 없음)
- `AudioStreamPlayer3D` = 실제 스피커 (가까울수록 크게, 멀면 작게)

---

### AudioStreamPlayer 기본 사용

```gdscript
@onready var bgm: AudioStreamPlayer = $BGMPlayer
@onready var sfx: AudioStreamPlayer = $SFXPlayer

# 재생
bgm.play()
sfx.play()

# 처음부터 재생
bgm.play(0.0)

# 특정 위치부터 재생 (초 단위)
bgm.play(10.5)   # 10.5초 지점부터

# 정지
bgm.stop()

# 볼륨 (dB 단위)
# 0 dB = 원본 볼륨, -10 dB ≈ 절반, -inf = 무음
bgm.volume_db = 0.0    # 원본 볼륨
bgm.volume_db = -10.0  # 약 절반 볼륨
bgm.volume_db = -80.0  # 거의 무음

# 재생 속도 (1.0 = 보통, 0.5 = 절반 속도, 2.0 = 2배 빠름)
sfx.pitch_scale = 1.0 + randf_range(-0.1, 0.1)  # 미세한 랜덤 음조로 단조로움 방지

# 재생 중 확인
if bgm.playing:
    bgm.stop()

# 재생 완료 Signal
sfx.finished.connect(_on_sfx_finished)
```

**Inspector에서 설정:**
- `Stream`: `.ogg`, `.wav`, `.mp3` 파일 드래그해서 연결
- `Autoplay`: 씬 시작 시 자동 재생 (BGM에 유용)
- `Loop`: 루프 재생 (OGG 파일의 경우 임포트 설정에서 루프 ON)

---

### 오디오 파일 임포트 설정

파일시스템에서 오디오 파일을 클릭하면 Inspector에 임포트 설정이 나온다:

```
BGM(.ogg) 권장 설정:
  Loop: ON        ← 무한 반복
  Compression Mode: Vorbis Quality 0.7  ← 용량/품질 균형

효과음(.wav) 권장 설정:
  Loop: OFF       ← 한 번만 재생
  Compression Mode: PCM (무압축, 짧은 파일에 적합)
```

---

### AudioStreamPlayer3D — 3D 공간 오디오

```gdscript
@onready var footstep: AudioStreamPlayer3D = $FootstepPlayer

# 3D 오디오 범위 설정 (Inspector 또는 코드)
footstep.max_distance = 20.0   # 이 거리 밖은 소리가 안 들림
footstep.unit_size = 5.0       # 이 거리에서 원본 볼륨 (가까울수록 큼)

# 감쇠 모델 (거리에 따른 볼륨 감소 방식)
footstep.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
# INVERSE_DISTANCE: 거리에 반비례 (자연스러움)
# DISABLED: 거리와 무관하게 일정 볼륨
```

---

### 오디오 풀링 — 동시 효과음 재생

**문제:** `sfx.play()`를 빠르게 연속 호출하면 이전 소리가 끊기고 새 소리만 재생된다.

**해결:** AudioStreamPlayer를 여러 개 준비해두고 돌아가며 사용하는 "풀링":

```gdscript
# audio_manager.gd (Autoload)
extends Node

const POOL_SIZE = 5
var sfx_pool: Array[AudioStreamPlayer] = []
var pool_index: int = 0

func _ready() -> void:
    for i in POOL_SIZE:
        var player = AudioStreamPlayer.new()
        add_child(player)
        sfx_pool.append(player)

# 효과음 재생 (풀에서 빈 슬롯 또는 가장 오래된 슬롯 사용)
func play_sfx(stream: AudioStream, volume: float = 0.0) -> void:
    var player = sfx_pool[pool_index]
    pool_index = (pool_index + 1) % POOL_SIZE  # 다음 슬롯으로 순환
    player.stream = stream
    player.volume_db = volume
    player.play()
```

---

### BGM 페이드 전환

씬 전환 시 BGM이 딱딱하게 끊기는 대신 부드럽게 전환:

```gdscript
# audio_manager.gd에 추가
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

func play_bgm(stream: AudioStream, fade_duration: float = 1.0) -> void:
    if bgm_player.stream == stream:
        return  # 이미 재생 중이면 무시

    if bgm_player.playing:
        # 페이드 아웃 후 새 BGM 재생
        var tween = create_tween()
        tween.tween_property(bgm_player, "volume_db", -80.0, fade_duration / 2)
        await tween.finished
        bgm_player.stop()

    # 새 BGM 페이드 인
    bgm_player.stream = stream
    bgm_player.volume_db = -80.0
    bgm_player.play()
    var tween = create_tween()
    tween.tween_property(bgm_player, "volume_db", 0.0, fade_duration / 2)

func stop_bgm(fade_duration: float = 1.0) -> void:
    var tween = create_tween()
    tween.tween_property(bgm_player, "volume_db", -80.0, fade_duration)
    await tween.finished
    bgm_player.stop()
```

---

### 오디오 Bus (믹서)

볼륨을 그룹별로 조절하는 시스템. 설정 메뉴에서 "음악 볼륨"과 "효과음 볼륨"을 따로 조절할 때 필수.

```
Master Bus (최종 출력)
├── Music Bus   (BGM만 — 음악 볼륨 슬라이더로 조절)
├── SFX Bus     (효과음만 — 효과음 볼륨 슬라이더로 조절)
└── Voice Bus   (대사만 — 자막 설정과 연동 가능)
```

**설정:** 에디터 하단 `Audio` 탭 클릭 → `Add Bus` 로 Bus 추가

**노드를 특정 Bus로 연결:**
Inspector → Bus 속성에서 Bus 이름 선택

```gdscript
# Bus 볼륨 조절 (0.0~1.0 값을 dB로 변환)
func set_music_volume(linear: float) -> void:
    # linear 0.0~1.0 → dB 변환
    var db = linear_to_db(linear)  # Godot 내장 함수
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

# Bus 음소거
func mute_sfx(muted: bool) -> void:
    AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), muted)
```

**음량 저장/불러오기 (설정 메뉴):**
```gdscript
# 설정 저장 (ConfigFile 사용)
var config = ConfigFile.new()
config.set_value("audio", "music_volume", 0.8)
config.set_value("audio", "sfx_volume", 1.0)
config.save("user://settings.cfg")

# 설정 불러오기
config.load("user://settings.cfg")
var music_vol = config.get_value("audio", "music_volume", 1.0)  # 기본값 1.0
set_music_volume(music_vol)
```

---

### 발소리 구현 패턴

```gdscript
# player.gd에 추가
@export var footstep_sound: AudioStream

@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer
var footstep_timer: float = 0.0
const FOOTSTEP_INTERVAL: float = 0.4  # 발소리 간격 (초)

func _physics_process(delta: float) -> void:
    # ... 기존 이동 코드 ...

    # 발소리: 바닥에 있고 이동 중일 때만
    if is_on_floor() and velocity.length() > 0.5:
        footstep_timer -= delta
        if footstep_timer <= 0.0:
            footstep_player.pitch_scale = 1.0 + randf_range(-0.1, 0.1)  # 음조 랜덤
            footstep_player.play()
            footstep_timer = FOOTSTEP_INTERVAL
    else:
        footstep_timer = 0.0  # 멈추면 즉시 다음 발소리 준비
```

---

### 무료 사운드 소스

| 사이트 | 특징 | 권장 용도 |
|--------|------|---------|
| [Kenney.nl](https://kenney.nl/assets?q=audio) | 게임용 팩, 완전 무료 상업 사용 | 효과음 팩 |
| [Freesound.org](https://freesound.org) | 다양한 효과음, 라이선스 확인 필요 | 특정 효과음 검색 |
| [OpenGameArt](https://opengameart.org) | BGM + 효과음, 무료 | BGM |
| [Incompetech](https://incompetech.com) | Kevin MacLeod의 BGM | BGM |

**파일 형식:**
- `.ogg` — BGM에 권장 (압축, 루프 지원, 작은 용량)
- `.wav` — 효과음에 권장 (무압축, 짧은 지연)
- `.mp3` — 특허 만료로 사용 가능하지만 ogg 권장

---

## 실습

### 실습 14-1: 오디오 매니저 만들기
Claude에게 다음 요청:

> "Godot 4에서 오디오 매니저 Autoload를 만들어줘.
> - `res://scripts/audio_manager.gd`, Autoload 이름: 'AudioManager'
> - BGM: AudioStreamPlayer 1개 (volume 조절, 페이드 전환 지원)
> - SFX 풀: AudioStreamPlayer 5개 (동시 효과음 재생)
> - 함수:
>   - `play_sfx(stream: AudioStream, volume_db: float = 0.0)`: 풀에서 재생
>   - `play_bgm(stream: AudioStream)`: 현재 BGM 페이드 아웃 후 새 BGM 페이드 인 (0.5초)
>   - `stop_bgm()`: BGM 페이드 아웃 후 정지
>   - `set_music_volume(linear: float)`: 0.0~1.0 → dB 변환 후 Music Bus에 적용
>   - `set_sfx_volume(linear: float)`: SFX Bus 볼륨 설정
>   - `save_settings()`, `load_settings()`: user://settings.cfg에 볼륨 저장/불러오기
> - Autoload 등록도 project.godot에 추가해줘"

### 실습 14-2: 발소리 & 환경음
Claude에게 다음 요청:

> "플레이어 스크립트에 발소리를 추가해줘.
> - `res://scripts/player.gd` 수정
> - 이동 중이고 바닥에 있을 때만 발소리 재생 (0.4초 간격)
> - 점프할 때 점프음, 착지할 때 착지음
> - 각 발소리마다 pitch_scale을 ±10% 랜덤 적용 (단조로움 방지)
> - AudioStreamPlayer를 Player 노드에 자식으로 추가
> - 실제 파일은 없다고 가정하고, @export AudioStream 변수로 Inspector에서 연결하게 해줘
>   (footstep_sound, jump_sound, land_sound)"

---

## 확인 포인트
- [ ] BGM과 효과음에 다른 노드 종류를 쓰는 이유를 안다
- [ ] `AudioStreamPlayer3D`가 거리에 따라 볼륨이 달라지는 것을 안다
- [ ] 오디오 풀링이 왜 필요한지 안다 (동시 재생, 끊기지 않게)
- [ ] `linear_to_db()` 변환이 왜 필요한지 안다 (볼륨은 선형이 아닌 로그 스케일)
- [ ] Audio Bus로 BGM/SFX 볼륨을 분리 조절할 수 있다
- [ ] `pitch_scale`로 같은 효과음을 다양하게 변형할 수 있다
- [ ] OGG는 BGM, WAV는 효과음에 적합한 이유를 안다

## 다음 챕터
[Ch15 — 씬 전환 & 세이브](./ch15_scene_save.md)
