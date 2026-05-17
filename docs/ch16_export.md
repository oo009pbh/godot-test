# Ch16 — 빌드 & 배포

> 만든 게임을 다른 사람이 플레이할 수 있도록 패키징하고, Steam / App Store / Google Play에
> 배포하는 흐름을 이해한다. macOS 개발 환경 기준.

---

## 개념

### 왜 빌드가 필요한가

Godot 에디터를 설치하지 않은 사람은 `.tscn`이나 `.gd` 파일을 직접 실행할 수 없다.
"빌드(Export)"는 게임 엔진과 모든 파일을 하나로 묶어서
**에디터 없이도 실행 가능한 파일**로 만드는 과정이다.

---

### Export Template 설치

각 플랫폼에 맞는 빌드 도구(Export Template)를 먼저 설치해야 한다.

```
1. Godot 에디터 상단 메뉴 → Editor → Manage Export Templates
2. "Download and Install" 클릭
3. 현재 Godot 버전에 맞는 템플릿 다운로드 (약 400MB~1GB)
4. 설치 완료 확인
```

**주의:** Export Template 버전이 Godot 에디터 버전과 **정확히** 일치해야 한다.
Godot 4.6.1이면 Export Template도 4.6.1이어야 한다.

---

### 플랫폼별 빌드 결과물

| 플랫폼 | 출력물 | 배포처 |
|--------|--------|--------|
| macOS | `.app` 번들 (`.zip`) | Mac App Store, Steam, 직접 배포 |
| Windows | `.exe` + `.pck` | Steam, 직접 배포 |
| iOS | `.ipa` | App Store |
| Android | `.aab` (권장) / `.apk` | Google Play |

---

### 빌드 전 project.godot 점검

빌드 전에 이 항목들을 확인한다:

```ini
[application]
config/name="내 게임 이름"             # 게임 이름
config/version="1.0.0"                # 버전 (배포 심사에 표시됨)
config/icon="res://assets/icon.png"   # 게임 아이콘 (1024x1024 PNG 권장)
run/main_scene="res://scenes/ui/main_menu.tscn"  # 시작 씬

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"   # 다른 화면 크기에 맞게 스케일
window/stretch/aspect="keep"         # 비율 유지 (늘어지지 않게)
```

**아이콘 크기 주의:**
- 스팀: 최소 512×512
- App Store / Google Play: 1024×1024 (플랫폼이 자동으로 리사이즈함)

---

### Debug vs Release 빌드

| 종류 | 특징 | 사용 시점 |
|------|------|-----------|
| Debug | 에러 출력, 느림 | 개발·테스트 중 |
| Release | 에러 숨김, 빠름 | 실제 배포 |

Export 창 하단에서 선택 가능. 배포 시에는 반드시 **Release** 빌드.

---

## macOS 빌드

### 로컬 테스트 (서명 없이)

```
Project → Export → Add → macOS
Export Path: builds/mac/MyGame.zip
→ Export Project (Debug 또는 Release)
```

출력물: `.zip` 안에 `MyGame.app` 번들이 들어 있다.
압축 해제 후 더블클릭으로 바로 실행 가능 (본인 Mac에서만).

### Gatekeeper 문제

macOS는 서명·공증이 없는 앱을 기본으로 차단한다.
다른 사람 Mac에서 실행하려면:
- **임시 우회:** 앱 우클릭 → 열기 → "그래도 열기" 클릭 (한 번만)
- **공식 해제:** 아래 코드사이닝 + 공증 과정 필요

### 코드사이닝 & 공증 (배포 필수)

**전제조건:** 애플 개발자 계정 ($99/년)

```
1. Xcode → Preferences → Accounts → Apple ID 등록
2. 인증서 생성:
   - "Developer ID Application" (Mac App Store 외부 배포)
   - "Apple Distribution" (Mac App Store 배포)
3. Godot Export 설정:
   - Code Signing Identity: "Developer ID Application: 이름 (팀ID)"
   - Notarization: ✅ 체크
   - Apple Team ID: 애플 개발자 포털에서 확인
4. Export → 빌드 완료 후 자동 공증 요청 (수 분 소요)
5. 공증 완료 → 배포 가능
```

공증 없이 Mac App Store에는 올릴 수 없다.

---

## Steam 배포

### 개요

스팀은 PC(Windows/macOS/Linux) 게임의 가장 큰 배포 플랫폼이다.
Godot 게임을 스팀에 올리려면 **Steamworks SDK** 연동이 필요하다.

### 필요한 것

| 항목 | 내용 |
|------|------|
| Steamworks 계정 | store.steampowered.com/developer 등록 |
| 앱 등록 비용 | $100 USD (환불 가능 조건 있음) |
| GodotSteam 플러그인 | Godot용 Steamworks 바인딩 |
| Steam App ID | 앱 등록 후 발급 |

### GodotSteam 플러그인

Godot에서 Steamworks SDK를 직접 쓰기 위한 오픈소스 플러그인.
다운로드: `godotsteam.com`

```gdscript
# GodotSteam 사용 예시
func _ready() -> void:
    Steam.steamInit()

func _process(_delta: float) -> void:
    Steam.run_callbacks()  # 반드시 매 프레임 호출

# 스팀 업적 달성
func unlock_achievement(name: String) -> void:
    Steam.setAchievement(name)
    Steam.storeStats()

# 스팀 리더보드 점수 업로드
func upload_score(score: int) -> void:
    Steam.uploadLeaderboardScore(leaderboard_id, Steam.LEADERBOARD_UPLOAD_SCORE_METHOD_KEEP_BEST, score, [])
```

### 스팀 배포 흐름

```
1. Steamworks 파트너 계정 생성 (partner.steamgames.com)
2. 새 앱 등록 → App ID 발급 ($100 USD)
3. GodotSteam 플러그인 적용 → App ID 설정
4. macOS + Windows Release 빌드 (각각)
5. Steamworks 백엔드 → SteamPipe로 빌드 업로드
6. 스팀 상점 페이지 작성 (스크린샷, 설명, 트레일러)
7. 출시 30일 전 검토 요청
8. 승인 후 출시일 설정 → 배포
```

---

## iOS / App Store 배포

### 전제조건

- 애플 개발자 계정 ($99/년)
- macOS + Xcode 설치
- iPhone/iPad 또는 시뮬레이터

### 빌드 흐름

```
1. Godot → Export → iOS
   Export Path: builds/ios/MyGame.xcodeproj
2. Xcode에서 xcodeproj 열기
3. Signing & Capabilities → 팀 선택 (애플 개발자 계정)
4. Product → Archive
5. Organizer → Distribute App → App Store Connect
6. App Store Connect에서 앱 심사 제출
```

### Godot iOS 주요 설정

```
Export → iOS:
  Bundle Identifier: com.회사이름.게임이름  ← 애플 계정과 일치해야 함
  Version: 1.0.0
  Short Version: 1.0
  Signing: Automatic (Xcode가 처리)
  Privacy: 사용하는 권한만 체크
    - 카메라: ❌ (3D 게임이라면 보통 불필요)
    - 마이크: ❌
    - 위치: ❌
```

**iOS 해상도 대응:**
iPhone의 다양한 화면(Safe Area)을 고려해야 한다.
Godot 4는 `DisplayServer.get_display_safe_area()`로 Safe Area를 읽을 수 있다.

---

## Android / Google Play 배포

### 전제조건

- Google Play 개발자 계정 ($25 USD 일회성)
- JDK 17 이상
- Android SDK (Android Studio 설치로 해결)
- 디버그 및 릴리즈 키스토어

### 빌드 흐름

```
1. Android Studio 설치 → SDK 경로 확인
   (예: ~/Library/Android/sdk)
2. Godot → Editor → Editor Settings
   → Export → Android → SDK 경로 입력
3. 키스토어 생성 (릴리즈용):
   keytool -genkey -v -keystore mygame.keystore
           -alias mygame -keyalg RSA -keysize 2048 -validity 10000
4. Godot → Export → Android
   - Keystore 경로 설정
   - Export AAB (권장, Google Play 필수)
5. Google Play Console → 새 앱 만들기
6. 프로덕션 트랙에 AAB 업로드 → 심사 제출
```

### APK vs AAB

| 형식 | 용도 |
|------|------|
| `.apk` | 직접 설치 (사이드로드, 테스트용) |
| `.aab` | Google Play 업로드 필수 형식 |

배포 시에는 `.aab`(Android App Bundle)로 Export해야 한다.

---

### 플랫폼 비교

| 플랫폼 | 비용 | 심사 기간 | 수익 분배 |
|--------|------|-----------|-----------|
| Steam | $100/앱 | 약 3~7일 | 개발자 70~88% |
| App Store (iOS/Mac) | $99/년 | 1~3일 | 개발자 70~85% |
| Google Play | $25 일회성 | 수 시간~3일 | 개발자 70~85% |

---

## 배포 전 최종 체크리스트

```
[ ] 게임 이름과 버전이 project.godot에 설정되어 있다
[ ] 아이콘이 res://assets/icon.png에 있다 (1024x1024 PNG)
[ ] 메인 씬이 main_menu.tscn으로 설정되어 있다
[ ] Release 빌드로 Export했다
[ ] 빌드된 파일을 직접 실행해서 시작~끝 플레이해봤다
[ ] Output에 에러가 표시되지 않는다
[ ] 볼륨이 적당하다
[ ] 다른 해상도에서도 UI가 잘 보인다
[ ] 대상 플랫폼의 개발자 계정이 준비되어 있다
[ ] 각 플랫폼 가이드라인을 확인했다 (연령 등급, 개인정보처리방침 등)
```

---

## 실습

### 실습 16-1: macOS 빌드 & 로컬 실행

```
1. Editor → Manage Export Templates → 설치 확인
2. Project → Export → Add → macOS
3. Export Path: res://builds/mac/MyGame.zip
4. Export Project (Release 모드)
5. builds/mac/ 폴더에서 zip 압축 해제
6. MyGame.app 더블클릭 → 실행 확인
   (처음엔 우클릭 → 열기 필요할 수 있음)
```

### 실습 16-2: 빌드 준비 — project.godot 정리

Claude에게 다음 요청:

> "우리 게임 project.godot를 빌드 배포 준비 상태로 정리해줘.
> - config/name='My 3D Game' 으로 설정
> - config/version='1.0.0' 추가
> - run/main_scene이 main_menu.tscn인지 확인
> - 해상도 1280x720, stretch mode canvas_items, aspect keep 설정
> - 메인 메뉴 UI 오른쪽 아래에 버전 표시 Label 추가 (작은 글씨, 반투명)
>   ProjectSettings.get_setting('application/config/version')으로 읽어서 표시"

### 실습 16-3: 플랫폼 배포 흐름 파악

Claude에게 질문:

> "우리 게임을 스팀에 올리려면 GodotSteam 플러그인 설정부터
> SteamPipe 업로드까지 단계별로 정리해줘.
> 현재 project.godot와 scripts/ 구조 기준으로 어디에 무엇을 추가해야 하는지 알려줘."

---

## 확인 포인트
- [ ] Export Template을 설치해야 빌드할 수 있다는 것을 안다
- [ ] macOS 배포 시 코드사이닝과 공증이 필요한 이유를 안다
- [ ] Steam 배포에 GodotSteam 플러그인이 필요하다는 것을 안다
- [ ] App Store 배포는 Xcode + 애플 개발자 계정이 필요하다는 것을 안다
- [ ] Google Play 배포는 `.aab` 형식이 필요하다는 것을 안다
- [ ] Debug 빌드와 Release 빌드의 차이를 안다

## 다음 챕터
[Ch17 — 미니 프로젝트 (종합)](./ch17_mini_project.md)
