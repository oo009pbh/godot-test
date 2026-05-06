# Ch16 — 빌드 & 배포

> 만든 게임을 다른 사람이 플레이할 수 있도록 패키징하고 배포하는 방법을 이해한다.
> Web 빌드로 브라우저에서 바로 플레이 가능한 게임을 itch.io에 올리는 것이 가장 빠른 공유 방법이다.

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

| 플랫폼 | 출력물 | 추가 요구사항 |
|--------|--------|--------------|
| Windows | `.exe` + `.pck` | 없음 (같은 폴더에 두 파일 함께) |
| macOS | `.app` 번들 | 애플 공증(Notarization) (배포 시) |
| Linux | 실행파일 | 없음 |
| Web | `.html` + `.js` + `.wasm` + `.pck` | 웹서버 필요 (COOP/COEP 헤더) |
| Android | `.apk` | JDK, Android SDK, 디버그 키스토어 |
| iOS | `.ipa` | macOS + Xcode + 애플 개발자 계정 |

---

### 빌드 전 project.godot 점검

빌드 전에 이 항목들을 확인한다:

```ini
[application]
config/name="내 게임 이름"           # 게임 이름
config/icon="res://assets/icon.png"  # 게임 아이콘 (256x256 PNG 권장)
run/main_scene="res://scenes/ui/main_menu.tscn"  # 시작 씬

[display]
window/size/viewport_width=1280     # 기준 해상도 너비
window/size/viewport_height=720     # 기준 해상도 높이
window/stretch/mode="canvas_items"  # 해상도 대응 (다른 화면 크기에 맞게 늘림)
window/stretch/aspect="keep"        # 비율 유지 (늘어지지 않게)

[rendering]
renderer/rendering_method="forward_plus"  # Forward+ (고성능 GPU 필요)
# 저사양 대상: "mobile" 또는 "gl_compatibility"
```

---

### 빌드 과정

```
1. Project → Export...
2. "Add..." → 플랫폼 선택 (Windows Desktop / Web / macOS 등)
3. Export Path 설정
   - Windows: builds/windows/게임이름.exe
   - Web: builds/web/index.html
4. 옵션 설정 (필요시)
5. "Export Project" 클릭
```

**Debug vs Release 빌드:**
- **Debug**: 에러 메시지 출력, 느림, 개발 중 테스트용
- **Release**: 에러 메시지 없음, 빠름, 최종 배포용

Export 창 하단에서 선택 가능. 배포 시에는 반드시 **Release** 빌드.

---

### Windows 빌드 주의사항

```
출력물:
  게임이름.exe    ← 실행 파일
  게임이름.pck    ← 게임 데이터 (같은 폴더에 있어야 함!)

zip으로 묶어서 배포:
  game.zip
  ├── MyGame.exe
  └── MyGame.pck
```

`.pck` 파일이 없으면 `.exe`가 실행되지 않는다.
항상 두 파일을 같이 배포해야 한다.

---

### Web 빌드 & itch.io 배포

**가장 빠른 배포 방법:** Web 빌드 → itch.io 업로드 → 링크 공유

**1. Web 빌드:**
```
Export → Web → builds/web/index.html 로 빌드
```

출력 파일들:
```
builds/web/
├── index.html     ← 메인 페이지
├── 게임이름.js
├── 게임이름.wasm
└── 게임이름.pck
```

**2. itch.io 업로드:**
```
1. itch.io 계정 생성 (무료)
2. Dashboard → Create new project
3. Title, Kind: HTML (Browser game)
4. Uploads: builds/web/ 폴더 전체를 .zip으로 압축해서 업로드
5. "This file will be played in the browser" 체크
6. Save → View page
```

**COOP/COEP 설정 (SharedArrayBuffer 오류 발생 시):**
itch.io의 게임 페이지 설정에서 "SharedArrayBuffer support" 옵션을 활성화한다.
이 설정이 없으면 Godot 4 Web 빌드가 멀티스레딩 관련 오류를 낼 수 있다.

---

### macOS 빌드

**개인 사용/테스트:**
```
Export → macOS → 게임이름.zip 또는 .app
```

**공개 배포 (Gatekeeper 우회):**
macOS는 서명되지 않은 앱을 기본적으로 차단한다.

- **무료 방법:** 사용자에게 "우클릭 → 열기"로 처음 한 번 실행하게 안내
- **공식 방법:** 애플 개발자 계정($99/년) + 공증(Notarization)

---

### 배포 전 최종 체크리스트

```
[ ] 게임 이름이 project.godot에 설정되어 있다
[ ] 아이콘이 res://assets/icon.png에 있다 (256x256 PNG)
[ ] 메인 씬이 main_menu.tscn으로 설정되어 있다
[ ] Release 빌드로 Export했다
[ ] 빌드된 파일을 직접 실행해서 테스트했다
[ ] 시작부터 끝까지 플레이해봤다
[ ] 에러가 Output에 표시되지 않는다
[ ] 볼륨이 적당하다
[ ] 해상도가 다른 화면에서도 UI가 잘 보인다
```

---

### 버전 관리

```ini
# project.godot에 버전 정보 추가
[application]
config/version="1.0.0"
```

```gdscript
# 코드에서 버전 읽기 (크레딧 화면, 디버그 정보)
var version = ProjectSettings.get_setting("application/config/version")
$VersionLabel.text = "v" + version
```

---

## 실습

### 실습 16-1: Windows 빌드
```
1. Editor → Manage Export Templates → 설치 확인
2. Project → Export → Add → Windows Desktop
3. Export Path: res://builds/windows/게임이름.exe
4. Export Project (Release 모드)
5. builds/windows/ 폴더에 .exe와 .pck 확인
6. .exe 직접 더블클릭해서 실행 확인
```

### 실습 16-2: Web 빌드 & itch.io 업로드
```
1. Project → Export → Add → Web
2. Export Path: res://builds/web/index.html
3. Export Project
4. builds/web/ 폴더 전체를 zip으로 압축
5. itch.io 에 새 프로젝트 생성 (Kind: HTML)
6. zip 파일 업로드
7. "This file will be played in the browser" 체크
8. Publish → 링크 복사해서 친구에게 공유
```

### 실습 16-3: 빌드 전 최종 점검
Claude에게 다음 요청:

> "우리 게임 project.godot를 빌드 배포 준비 상태로 정리해줘.
> - config/name이 적절한 게임 이름인지 확인하고 설정
> - config/version='1.0.0' 추가
> - run/main_scene이 main_menu.tscn인지 확인
> - 해상도 1280x720, stretch mode canvas_items로 설정
> - 메인 메뉴에 버전 표시 Label 추가 (오른쪽 아래, 작은 글씨)
>   ProjectSettings.get_setting('application/config/version')으로 읽어서 표시"

---

## 확인 포인트
- [ ] Export Template을 설치해야 빌드할 수 있다는 것을 안다
- [ ] Windows 빌드 결과물이 .exe와 .pck 두 파일임을 안다 (함께 배포)
- [ ] Debug 빌드와 Release 빌드의 차이를 안다
- [ ] Web 빌드로 itch.io에 올려서 브라우저에서 바로 플레이 가능한 것을 안다
- [ ] `run/main_scene`이 게임 시작 씬임을 안다
- [ ] `window/stretch/mode`로 해상도 대응을 설정하는 것을 안다

## 다음 챕터
[Ch17 — 미니 프로젝트 (종합)](./ch17_mini_project.md)
