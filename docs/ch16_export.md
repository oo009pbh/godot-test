# Ch16 — 빌드 & 배포

---

## 개념

### Export Template
Godot은 각 플랫폼별 Export Template을 설치해야 빌드할 수 있다.

**설치 경로:**
`Editor → Manage Export Templates → Download and Install`

### 플랫폼별 Export

| 플랫폼 | 출력물 | 비고 |
|--------|--------|------|
| Windows | `.exe` + `.pck` | 64bit 권장 |
| macOS | `.app` 번들 | 애플 공증(Notarization) 필요 |
| Linux | 실행파일 | |
| Web | `.html` + `.js` + `.wasm` | itch.io에 바로 올릴 수 있음 |
| Android | `.apk` | JDK, Android SDK 필요 |

### 빌드 과정

```
1. Project → Export...
2. Add... → 플랫폼 선택
3. Export Path 설정 (저장 위치)
4. Options 설정:
   - Encryption Key (선택)
   - Icon
5. Export Project 클릭
```

### project.godot 최종 점검 사항
```
[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"  ← 해상도 대응

[application]
config/name="내 게임 이름"
config/icon="res://icon.png"
run/main_scene="res://scenes/ui/main_menu.tscn"
```

### itch.io에 Web으로 배포하기
1. Godot에서 Web Export → `index.html` 포함한 폴더 생성
2. itch.io 계정 만들기
3. "Upload a new project" → HTML 파일들 zip 업로드
4. "Kind of project: HTML" 선택
5. 공유 링크 생성

**무료이고 가장 빠른 배포 방법**

---

## 실습

### 실습 16-1: Windows 빌드
1. Export Template 설치 (에디터에서 다운로드)
2. `Project → Export → Add → Windows Desktop`
3. `builds/windows/게임이름.exe`로 Export
4. 빌드된 `.exe` 직접 실행해서 확인

### 실습 16-2: Web 빌드 & itch.io 업로드
1. Export Template에서 Web 설치
2. `Project → Export → Add → Web`
3. `builds/web/index.html`로 Export
4. `builds/web/` 폴더를 zip으로 압축
5. itch.io에 업로드

---

## 확인 포인트
- [ ] Export Template을 설치해야 빌드할 수 있다는 것을 안다
- [ ] Web 빌드로 브라우저에서 바로 플레이 가능한 것을 안다
- [ ] `run/main_scene`이 게임 시작 씬임을 안다

## 다음 챕터
[Ch17 — 미니 프로젝트 (종합)](./ch17_mini_project.md)
