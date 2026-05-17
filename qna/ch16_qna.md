# Ch16 Q&A

---

## Q1. 우리 게임을 스팀에 올리려면 GodotSteam 플러그인 설정부터 SteamPipe 업로드까지 단계별로 정리해줘. 현재 project.godot와 scripts/ 구조 기준으로 어디에 무엇을 추가해야 하는지 알려줘.

**GodotSteam 플러그인을 설치하고, scripts/에 SteamManager를 추가한 뒤, Steamworks 백엔드에 빌드를 업로드하면 된다.**

스팀은 게임 엔진과 직접 대화하지 않는다. **Steamworks SDK**라는 C++ 라이브러리를 통해야 하는데,
Godot에서 이걸 쓸 수 있게 GDScript로 감싸 놓은 것이 **GodotSteam 플러그인**이다.

---

### 1단계: Steamworks 계정 & App ID 발급

```
1. partner.steamgames.com → 파트너 계정 생성
2. 새 앱 등록 → $100 USD 결제
3. App ID 발급 (예: 480 → 실제 앱은 고유 숫자)
```

---

### 2단계: GodotSteam 플러그인 설치

GodotSteam은 Godot 에디터 안에 내장되지 않는다.
**GodotSteam 전용으로 빌드된 Godot 에디터**를 따로 설치해야 한다.

```
1. godotsteam.com → "GDExtension" 버전 다운로드
   (우리 프로젝트는 Godot 4.6 → GodotSteam for Godot 4.x 선택)
2. 다운로드한 파일 안의 addons/ 폴더를
   우리 프로젝트 루트에 복사:
   새-게임-프로젝트/addons/godotsteam/
3. project.godot → Plugins 탭 → GodotSteam 활성화
```

project.godot에 자동으로 추가되는 항목:

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/godotsteam/plugin.cfg")
```

---

### 3단계: scripts/에 SteamManager 추가

우리 프로젝트의 scripts/ 구조에 `steam_manager.gd`를 추가한다.

```
scripts/
├── game_manager.gd      ← 기존 (GameManager autoload)
├── save_manager.gd      ← 기존
├── audio_manager.gd     ← 기존
└── steam_manager.gd     ← 신규 추가
```

`scripts/steam_manager.gd` 내용:

```gdscript
extends Node

const APP_ID := 480  # 실제 App ID로 교체

func _ready() -> void:
    var init_result: Dictionary = Steam.steamInit(true, APP_ID)
    if init_result["status"] != Steam.RESULT_OK:
        push_error("Steam init 실패: " + str(init_result["verbal"]))
        return
    print("Steam 초기화 성공. 유저: ", Steam.getPersonaName())

func _process(_delta: float) -> void:
    Steam.run_callbacks()  # 매 프레임 반드시 호출

func unlock_achievement(achievement_name: String) -> void:
    Steam.setAchievement(achievement_name)
    Steam.storeStats()
```

`project.godot`에 autoload 등록:

```ini
[autoload]
SteamManager="*res://scripts/steam_manager.gd"
```

**등록 순서 주의:** SteamManager는 GameManager보다 먼저 초기화되어야 한다.
`project.godot`의 autoload 목록에서 맨 위에 배치한다.

---

### 4단계: steam_appid.txt 생성

실행 파일과 같은 폴더에 `steam_appid.txt`를 만들어야
스팀 클라이언트가 어떤 앱인지 인식한다.

```
# 프로젝트 루트에 생성 (개발용, 배포 빌드에는 포함 금지)
480
```

`.gitignore`에 추가:

```
steam_appid.txt
```

---

### 5단계: macOS + Windows Release 빌드

```
1. Project → Export → macOS → Export Project (Release)
   → builds/mac/MyGame.dmg
2. Project → Export → Windows → Export Project (Release)
   → builds/windows/MyGame.exe
```

두 플랫폼 빌드를 모두 준비한다.

---

### 6단계: SteamPipe로 빌드 업로드

Steamworks 백엔드에 빌드를 올리는 도구가 **SteamPipe**다.

```
1. Steamworks 파트너 사이트 → SteamPipe 도구 다운로드
2. 앱 구성 VDF 파일 작성:
   app_build_480.vdf → 빌드 설명, 빌드 경로 지정
3. steamcmd.sh +login <계정> +run_app_build app_build_480.vdf
4. Steamworks 백엔드 → 빌드 확인 → "기본 빌드로 설정"
```

---

### 7단계: 상점 페이지 작성 & 출시

```
1. Steamworks → 상점 페이지 편집
   - 게임 설명, 스크린샷(최소 5장), 트레일러
   - 캡슐 이미지 (460×215, 231×87 등)
2. 출시 30일 전 검토 요청 제출
3. 승인 후 출시일 설정 → 배포
```

---

### 우리 프로젝트 기준 추가 위치 요약

| 추가 항목 | 위치 |
|-----------|------|
| GodotSteam 플러그인 | `addons/godotsteam/` |
| SteamManager 스크립트 | `scripts/steam_manager.gd` |
| autoload 등록 | `project.godot` → [autoload] 최상단 |
| 업적 연동 | `scripts/game_manager.gd` 또는 각 씬 스크립트에서 `SteamManager.unlock_achievement()` 호출 |
| 빌드 출력 | `builds/mac/`, `builds/windows/` |

---
