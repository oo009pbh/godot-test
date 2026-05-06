# Ch12 — UI / HUD

> 3D 게임에서 체력바, 점수, 크로스헤어 같은 화면 위 정보를 표시하는 방법을 이해한다.
> UI는 3D 씬과 완전히 분리된 별도 레이어에 올라간다.

---

## 개념

### 왜 UI가 3D 씬과 분리되어야 하는가

**문제 상황:**
체력바를 3D 씬 안에 그냥 놓으면 카메라가 움직일 때 체력바도 같이 이동한다.
체력바는 항상 화면 왼쪽 위에 고정되어 있어야 하는데.

**해결책: CanvasLayer**
`CanvasLayer`는 3D 렌더링 위에 2D 레이어를 덮는 시스템이다.
카메라가 어디를 보든 관계없이 **항상 화면에 고정**된다.

```
3D 렌더링 → [CanvasLayer UI] → 최종 화면
             (카메라와 무관하게 항상 고정)
```

---

### Control 노드 — UI의 기본 단위

3D 씬의 Node3D처럼, UI는 `Control` 노드를 기반으로 한다.

| Control 노드 | 용도 | 실용 예 |
|-------------|------|---------|
| `Label` | 텍스트 표시 | 점수, 체력 숫자, 대사 |
| `Button` | 클릭 가능한 버튼 | 메뉴 버튼, 확인/취소 |
| `ProgressBar` | 막대 형태 진행도 | 체력바, 경험치바, 로딩 |
| `TextureRect` | 이미지 표시 | 아이콘, 크로스헤어, 배경 이미지 |
| `Panel` | 배경 패널 | 인벤토리 배경, 대화창 |
| `VBoxContainer` | 세로 자동 정렬 | 메뉴 버튼 목록 |
| `HBoxContainer` | 가로 자동 정렬 | 아이템 슬롯 |
| `GridContainer` | 격자 정렬 | 인벤토리 |
| `ColorRect` | 단색 사각형 | 페이드 효과, 반투명 배경 |
| `RichTextLabel` | 색상/크기 혼합 텍스트 | 채팅, 데미지 숫자 |

---

### CanvasLayer 구조

```
World (Node3D)
├── DirectionalLight3D
├── Ground (StaticBody3D)
├── Player (CharacterBody3D)
└── HUD (CanvasLayer)              ← 항상 화면에 고정되는 레이어
    ├── HealthBar (ProgressBar)    ← 왼쪽 위
    ├── ScoreLabel (Label)         ← 오른쪽 위
    └── Crosshair (TextureRect)    ← 화면 정중앙
```

`CanvasLayer`에 들어간 모든 자식 노드는 카메라와 무관하게 화면에 고정된다.

---

### Anchor — UI 위치 고정

Control 노드를 **화면 어느 구석에 붙일지** 결정하는 것이 Anchor다.

**비유: 스티커 붙이기**
"이 스티커를 화면 왼쪽 위 모서리에 붙여라"처럼
Anchor가 UI를 화면의 특정 기준점에 고정한다.

Inspector → Layout → Anchors Preset 에서 선택:

| Anchor 프리셋 | 의미 | 사용 예 |
|-------------|------|---------|
| `Top Left` | 왼쪽 위 고정 | 체력바, 미니맵 |
| `Top Right` | 오른쪽 위 고정 | 점수, 시간 |
| `Bottom Left` | 왼쪽 아래 고정 | 대화창 |
| `Bottom Right` | 오른쪽 아래 고정 | 쿨다운 버튼 |
| `Center` | 화면 중앙 | 크로스헤어, 게임오버 텍스트 |
| `Full Rect` | 화면 전체 | 페이드 오버레이, 풀스크린 메뉴 |

**주요 속성:**
```
Margin: Anchor 기준점에서 얼마나 떨어뜨릴지 (픽셀)
Size: Control의 크기
```

---

### % 연산자 — 노드 빠른 접근

`@onready var` 대신 더 짧게 노드를 참조하는 방법:

```gdscript
# 방법 1: @onready (기존 방식)
@onready var health_bar: ProgressBar = $HealthBar

# 방법 2: % 연산자 (Unique Name)
# 에디터에서 노드를 우클릭 → "Access as Unique Name" 체크
%HealthBar.value = 80   # $ 대신 % 사용, 씬 어디에 있든 바로 접근 가능

# %의 장점: 씬 트리에서 노드 위치가 바뀌어도 참조가 깨지지 않음
```

---

### HUD와 GameManager 연결

GameManager의 Signal을 받아서 HUD를 자동으로 업데이트하는 패턴:

```gdscript
# res://scripts/hud.gd
extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var score_label: Label = $ScoreLabel
@onready var coin_label: Label = $CoinLabel

func _ready() -> void:
    # GameManager Signal 구독 — Signal이 오면 자동으로 아래 함수 호출
    GameManager.score_changed.connect(_on_score_changed)
    GameManager.health_changed.connect(_on_health_changed)

    # 초기값 설정 (씬 로드 시 현재 상태 반영)
    health_bar.value = GameManager.health
    score_label.text = "Score: %d" % GameManager.score

func _on_score_changed(new_score: int) -> void:
    score_label.text = "Score: %d" % new_score
    # 점수 올라갈 때 팝업 애니메이션 추가 가능
    _play_score_popup()

func _on_health_changed(new_health: int) -> void:
    health_bar.value = new_health
    # 체력 낮으면 빨갛게 깜빡이기
    if new_health < 30:
        health_bar.modulate = Color.RED
    else:
        health_bar.modulate = Color.WHITE

func _play_score_popup() -> void:
    var tween = create_tween()
    tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1)
    tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)
```

---

### RichTextLabel — BBCode로 텍스트 꾸미기

일반 Label로는 불가능한 색상/크기 혼합 텍스트:

```gdscript
# RichTextLabel의 bbcode_enabled = true 설정 필요
$RichTextLabel.text = "[color=red]데미지:[/color] [b]50[/b]"
$RichTextLabel.text = "[wave amp=25 freq=5]흔들리는 텍스트[/wave]"
$RichTextLabel.text = "[color=#FFD700]%d점[/color]" % score
```

---

### Tween으로 UI 애니메이션

```gdscript
# 체력바 부드럽게 감소
func update_health_smooth(new_health: int) -> void:
    var tween = create_tween()
    tween.tween_property(health_bar, "value", new_health, 0.3)

# 데미지 숫자 팝업 (위로 올라가면서 사라짐)
func show_damage_number(amount: int, position: Vector2) -> void:
    var label = Label.new()
    label.text = "-%d" % amount
    label.modulate = Color.RED
    label.position = position
    add_child(label)

    var tween = create_tween()
    tween.tween_property(label, "position:y", position.y - 50, 0.8)
    tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
    await tween.finished
    label.queue_free()
```

---

### 크로스헤어 (조준선)

```gdscript
# 화면 정중앙에 크로스헤어 배치
# TextureRect 사용 시: Inspector → Layout → Center

# 코드로 중앙에 위치시키기
func _ready() -> void:
    var screen_size = get_viewport().get_visible_rect().size
    $Crosshair.position = screen_size / 2 - $Crosshair.size / 2
```

---

### Theme — UI 전체 스타일 통일

폰트, 색상, 버튼 스타일을 Theme 리소스 하나로 관리:

```
1. Inspector → (임의의 Control 노드 선택) → Theme → New Theme
2. Theme 에디터에서 폰트, 색상, 버튼 스타일 설정
3. 프로젝트 전체 적용: Project Settings → GUI → Theme → Custom Theme
```

```gdscript
# 코드에서 Theme 속성 조정
var theme = Theme.new()
theme.set_font_size("font_size", "Label", 24)
theme.set_color("font_color", "Label", Color.WHITE)
$Label.theme = theme
```

---

## 실습

### 실습 12-1: 기본 HUD
Claude에게 다음 요청:

> "Godot 4에서 게임 HUD를 만들어줘.
> - `res://scenes/ui/hud.tscn`, `res://scripts/hud.gd`
> - CanvasLayer 기반
> - 왼쪽 위: 체력바 (ProgressBar, 최대값 100, 빨간색, 너비 200px)
> - 오른쪽 위: 점수 표시 (Label, 흰색 텍스트)
> - 화면 중앙: 크로스헤어 (작은 흰색 십자가, TextureRect 또는 ColorRect 조합)
> - GameManager의 health_changed, score_changed Signal에 자동 연결
> - 체력 30 이하면 체력바가 빨간색으로 깜빡이는 애니메이션 추가
> - 점수 변경 시 스케일 1.0→1.3→1.0 팝업 효과 추가"

### 실습 12-2: 일시정지 메뉴
Claude에게 다음 요청:

> "Godot 4에서 ESC로 열리는 일시정지 메뉴를 만들어줘.
> - `res://scenes/ui/pause_menu.tscn`, `res://scripts/pause_menu.gd`
> - 반투명 검은 배경 (ColorRect, 전체 화면, alpha 0.7)
> - 중앙에 VBoxContainer: 'Resume', 'Restart', 'Main Menu', 'Quit' 버튼
> - 버튼 폰트 크기 24, 최소 너비 200px
> - ESC 입력 → get_tree().paused 토글 + 메뉴 표시/숨김
> - Process Mode를 Always로 설정 (일시정지 중에도 버튼 작동)
> - Resume: 일시정지 해제, Restart: GameManager.reset() 후 씬 재로드
> - Main Menu: 'res://scenes/ui/main_menu.tscn'으로 전환"

### 실습 12-3: 데미지 숫자 팝업
Claude에게 다음 요청:

> "플레이어가 데미지를 받을 때 화면에 데미지 숫자가 팝업되는 효과를 추가해줘.
> - HUD의 CanvasLayer에 동적으로 Label을 추가하는 방식
> - 빨간 텍스트로 '-20' 같이 데미지 양 표시
> - 0.8초 동안 위로 떠오르면서 서서히 투명해짐
> - GameManager.health_changed Signal에서 이전 체력과 비교해 데미지 양 계산
> - hud.gd에 show_damage(amount, screen_position) 함수 추가"

---

## 확인 포인트
- [ ] CanvasLayer가 왜 HUD에 필요한지 안다 (카메라와 무관하게 화면 고정)
- [ ] Anchor로 UI를 화면 구석에 고정하는 방법을 안다
- [ ] GameManager Signal로 HUD를 업데이트하는 패턴을 안다
- [ ] Process Mode를 Always로 설정해야 일시정지 중에도 UI가 작동하는 이유를 안다
- [ ] Tween으로 UI 애니메이션(팝업, 페이드)을 만드는 방법을 안다
- [ ] `%NodeName` 문법이 `$` 대신 고유 이름으로 노드를 참조한다는 것을 안다

## 다음 챕터
[Ch13 — 파티클 & VFX](./ch13_vfx.md)
