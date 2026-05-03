# Ch12 — UI / HUD

---

## 개념

### Control 노드 — UI의 기본 단위
3D 씬과 별개로 화면에 고정된 UI는 모두 `Control` 노드를 사용한다.

| Control 노드 | 용도 |
|-------------|------|
| `Label` | 텍스트 표시 |
| `Button` | 클릭 가능한 버튼 |
| `ProgressBar` | 체력바, 로딩바 |
| `TextureRect` | 이미지 표시 |
| `Panel` | 배경 패널 |
| `VBoxContainer` | 세로 정렬 컨테이너 |
| `HBoxContainer` | 가로 정렬 컨테이너 |

### CanvasLayer — 3D 위에 UI 올리기
```
World (Node3D)
├── ... (3D 씬)
└── HUD (CanvasLayer)         ← 항상 최상단에 렌더링
    ├── HealthBar (ProgressBar)
    ├── ScoreLabel (Label)
    └── CrossHair (TextureRect)
```

`CanvasLayer`에 들어간 UI는 카메라가 움직여도 화면에 고정된다.

### Anchor — UI 위치 고정
Control 노드의 `Layout` 속성으로 화면 어느 곳에 고정할지 결정:

| Anchor 프리셋 | 의미 |
|-------------|------|
| Top Left | 왼쪽 위 고정 |
| Top Right | 오른쪽 위 고정 |
| Bottom Left | 왼쪽 아래 고정 |
| Center | 화면 중앙 |
| Full Rect | 화면 전체 채우기 |

### HUD와 GameManager 연결

```gdscript
# hud.gd
extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var score_label = $ScoreLabel

func _ready():
    # GameManager의 Signal에 연결
    GameManager.score_changed.connect(_on_score_changed)
    GameManager.health_changed.connect(_on_health_changed)

func _on_score_changed(new_score):
    score_label.text = "Score: %d" % new_score

func _on_health_changed(new_health):
    health_bar.value = new_health
```

### Theme — UI 전체 스타일
`Theme` 리소스 하나로 모든 UI의 폰트, 색상, 스타일을 통일할 수 있다:
```
Project Settings → Theme 또는 Control 노드의 Theme 속성에 적용
```

---

## 실습

### 실습 12-1: 기본 HUD
Claude에게 다음 요청:

> "Godot 4에서 게임 HUD를 만들어줘.
> - `res://scenes/ui/hud.tscn`
> - CanvasLayer 기반
> - 왼쪽 위: 체력바 (ProgressBar, 최대값 100)
> - 오른쪽 위: 점수 표시 (Label)
> - 화면 중앙: 크로스헤어 (작은 흰색 십자가)
> - GameManager의 health_changed, score_changed Signal에 자동으로 연결"

### 실습 12-2: 일시정지 메뉴
Claude에게 다음 요청:

> "Godot 4에서 ESC로 열리는 일시정지 메뉴를 만들어줘.
> - `res://scenes/ui/pause_menu.tscn`
> - 반투명 검은 배경
> - 'Resume', 'Main Menu', 'Quit' 버튼
> - 버튼들이 세로로 가운데 정렬
> - ESC 누르면 게임이 일시정지(get_tree().paused)되고 메뉴 표시
> - Resume 누르면 일시정지 해제
> - 이 UI는 일시정지 중에도 동작해야 해 (Process Mode: Always)"

---

## 확인 포인트
- [ ] CanvasLayer가 왜 HUD에 필요한지 안다
- [ ] Anchor로 UI를 화면 구석에 고정하는 방법을 안다
- [ ] GameManager Signal로 HUD를 업데이트하는 패턴을 안다
- [ ] 일시정지 시 Process Mode 설정이 필요한 이유를 안다

## 다음 챕터
[Ch13 — 파티클 & VFX](./ch13_vfx.md)
