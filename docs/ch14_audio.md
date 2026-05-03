# Ch14 — 오디오

---

## 개념

### 오디오 노드 종류

| 노드 | 설명 |
|------|------|
| `AudioStreamPlayer` | 위치 없는 2D 오디오 (BGM, UI 효과음) |
| `AudioStreamPlayer2D` | 2D 공간 오디오 |
| `AudioStreamPlayer3D` | 3D 공간 오디오 (거리에 따라 볼륨 감소) |

### AudioStreamPlayer 기본 사용

```gdscript
@onready var sfx = $AudioStreamPlayer

# 재생
sfx.play()

# 정지
sfx.stop()

# 볼륨 (dB 단위)
sfx.volume_db = -10.0  # -10dB = 약 절반 볼륨

# 재생 중 확인
if sfx.playing:
    sfx.stop()
```

**Inspector에서 설정:**
- `Stream`: `.ogg`, `.wav`, `.mp3` 파일 연결
- `Autoplay`: 씬 시작 시 자동 재생 (BGM에 유용)
- `Loop`: 루프 재생

### AudioStreamPlayer3D 거리 감쇠

```gdscript
# 3D 공간에서 사운드가 들리는 범위 설정
$AudioStreamPlayer3D.max_distance = 20.0   # 이 거리 밖은 안 들림
$AudioStreamPlayer3D.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
```

### 오디오 Bus (믹서)
볼륨을 그룹으로 조절:

```
Master Bus
├── Music Bus (BGM만)
├── SFX Bus (효과음만)
└── Voice Bus (대사만)
```

**설정:** `Audio → Audio...` 메뉴 (에디터 하단)

```gdscript
# Bus 볼륨 조절 (설정 화면 등에서)
AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -10.0)

# Bus 음소거
AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
```

### 무료 사운드 소스

| 사이트 | 특징 |
|--------|------|
| [Freesound.org](https://freesound.org) | 다양한 효과음, 라이선스 확인 필요 |
| [Kenney.nl audio](https://kenney.nl/assets?q=audio) | 게임용 팩, 무료 상업 사용 |
| [OpenGameArt](https://opengameart.org) | BGM + 효과음 |

---

## 실습

### 실습 14-1: 오디오 매니저 만들기
Claude에게 다음 요청:

> "Godot 4에서 오디오 매니저 Autoload를 만들어줘.
> - `res://scripts/audio_manager.gd`
> - Autoload 이름: 'AudioManager'
> - 함수:
>   - `play_sfx(stream: AudioStream)`: 효과음 재생 (풀링 방식)
>   - `play_bgm(stream: AudioStream)`: BGM 재생 (이미 재생 중이면 페이드 전환)
>   - `stop_bgm()`: BGM 정지
>   - `set_master_volume(vol: float)`: 0.0~1.0을 dB로 변환해서 설정
> - 효과음은 동시에 여러 개 재생 가능하게 AudioStreamPlayer 풀(5개) 사용"

### 실습 14-2: 발소리 & 환경음
Claude에게 다음 요청:

> "플레이어 스크립트에 발소리를 추가해줘.
> - 이동 중일 때만 발소리 재생 (걸을 때 / 멈출 때 자동 on/off)
> - 바닥에 닿아있을 때만 재생
> - AudioStreamPlayer 사용 (3D 위치 불필요)
> - `res://assets/audio/footstep.ogg` 파일을 사용한다고 가정
>   (파일 없으면 코드만 만들어줘, 나중에 파일 넣을 수 있게)"

---

## 확인 포인트
- [ ] BGM에는 `AudioStreamPlayer`, 발소리에는 `AudioStreamPlayer3D`가 적합한 이유를 안다
- [ ] Audio Bus로 BGM/SFX 볼륨을 분리 조절할 수 있다
- [ ] `autoplay`와 `loop`의 차이를 안다

## 다음 챕터
[Ch15 — 씬 전환 & 세이브](./ch15_scene_save.md)
