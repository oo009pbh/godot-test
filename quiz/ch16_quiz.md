# Ch16 퀴즈 — 빌드 & 배포

---

## 문제

**Q1.** Godot에서 게임을 빌드(Export)하는 이유는?

---

**Q2.** Export Template을 Godot 에디터 버전과 **정확히** 일치하게 설치해야 하는 이유는?

---

**Q3.** Debug 빌드와 Release 빌드의 차이를 설명하라. 배포 시 어느 것을 사용해야 하는가?

---

**Q4.** macOS에서 서명·공증 없이 빌드한 앱을 다른 사람 Mac에서 실행할 때 발생하는 문제는? 임시 우회 방법은?

---

**Q5.** `project.godot`에서 빌드 전 점검해야 할 항목을 3가지 이상 쓰라.

---

**Q6.** (O/X) iOS 빌드는 Windows PC에서도 할 수 있다.

---

**Q7.** macOS 빌드 출력물의 실제 형태는?

① `.exe` 파일 ② `.app` 번들이 담긴 `.zip` ③ `.apk` ④ `.ipa`

---

**Q8.** GodotSteam을 사용하려면 일반 Godot 에디터 대신 무엇을 설치해야 하는가? 그리고 프로젝트에 추가해야 하는 폴더는?

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.** Godot 에디터를 설치하지 않은 사람은 `.tscn`이나 `.gd` 파일을 직접 실행할 수 없다. 빌드(Export)는 게임 엔진과 모든 파일을 하나로 묶어서 에디터 없이도 실행 가능한 파일로 만드는 과정이다.

**Q2.** Godot 에디터와 Export Template의 내부 API가 정확히 일치해야 한다. 버전이 다르면 빌드 과정에서 충돌이 발생하거나 빌드된 게임이 정상 동작하지 않는다.

**Q3.**
- **Debug**: 에러 출력, 느림 — 개발·테스트 중 사용
- **Release**: 에러 숨김, 최적화되어 빠름 — 실제 배포 시 사용
배포 시에는 반드시 **Release** 빌드를 사용해야 한다.

**Q4.** macOS Gatekeeper가 서명·공증 없는 앱을 기본으로 차단한다. 임시 우회: 앱을 우클릭 → "열기" → "그래도 열기" 버튼 클릭 (처음 한 번만).

**Q5.** 다음 중 3가지 이상:
- `config/name`: 게임 이름 설정
- `config/version`: 버전 번호 (예: "1.0.0")
- `config/icon`: 게임 아이콘 파일 경로 (1024×1024 PNG 권장)
- `run/main_scene`: 시작 씬 설정
- `window/size`: 해상도 설정 (1280×720 등)
- `window/stretch/mode`: 화면 스케일 설정

**Q6.** X — iOS 빌드는 **macOS에서만** 가능하다. Xcode가 macOS 전용이기 때문이다.

**Q7.** ② `.app` 번들이 담긴 `.zip` — macOS 앱은 `.app` 번들 형태이고, 배포를 위해 `.zip`으로 압축된다.

**Q8.** GodotSteam 전용으로 빌드된 Godot 에디터(GDExtension 버전)를 설치해야 한다. 프로젝트에는 `addons/godotsteam/` 폴더를 추가하고 Plugin을 활성화해야 한다.

</details>
