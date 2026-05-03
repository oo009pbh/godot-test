# Ch11 — 게임 상태 관리

---

## 개념

### Autoload — 전역 싱글톤
어떤 씬에서도 접근 가능한 전역 스크립트.

**등록 방법:** `Project → Project Settings → Autoload`
- 이름: `GameManager` → 어디서든 `GameManager.변수/함수()`로 접근 가능

```gdscript
# res://scripts/game_manager.gd
extends Node

var score: int = 0
var health: int = 100
var current_level: int = 1

signal score_changed(new_score)
signal health_changed(new_health)
signal game_over

func add_score(amount: int):
    score += amount
    score_changed.emit(score)

func take_damage(amount: int):
    health -= amount
    health_changed.emit(health)
    if health <= 0:
        game_over.emit()
```

**다른 스크립트에서 접근:**
```gdscript
GameManager.add_score(100)
GameManager.health  # 현재 체력 읽기
```

### SceneTree — 씬 전환
```gdscript
# 씬 전환
get_tree().change_scene_to_file("res://scenes/level2.tscn")

# 씬 다시 로드 (재시작)
get_tree().reload_current_scene()

# 게임 종료
get_tree().quit()

# 일시정지
get_tree().paused = true
```

### 씬 전환 시 데이터 유지
씬이 바뀌면 모든 Node가 사라진다. 데이터를 유지하려면:

**방법 1: Autoload에 저장** (권장)
```gdscript
GameManager.score = current_score  # 씬 전환 전에 저장
# 새 씬에서
var score = GameManager.score      # 읽어서 사용
```

**방법 2: 다음 씬으로 전달**
```gdscript
# 전달하기 어려움 - Autoload를 쓰는 게 낫다
```

### 일시정지 처리
```gdscript
# ESC로 일시정지 토글
func _input(event):
    if event.is_action_just_pressed("ui_cancel"):
        get_tree().paused = !get_tree().paused
        pause_menu.visible = get_tree().paused

# 일시정지 중에도 동작하게 하려면 (UI 버튼 등)
# Node의 Process Mode를 "Always"로 설정
```

### Signal 기반 아키텍처
직접 참조 대신 Signal로 연결하면 씬 간 의존성이 낮아진다:

```
Enemy → (health_depleted Signal) → GameManager → (score_changed Signal) → HUD
```

```gdscript
# Enemy가 죽을 때
signal health_depleted
health_depleted.emit()

# GameManager에서 구독
enemy.health_depleted.connect(_on_enemy_died)

func _on_enemy_died():
    add_score(100)
```

---

## 실습

### 실습 11-1: GameManager Autoload
Claude에게 다음 요청:

> "Godot 4에서 GameManager Autoload를 만들어줘.
> - `res://scripts/game_manager.gd`
> - project.godot Autoload에 'GameManager'로 등록해줘
> - 관리할 데이터: score(int), health(int, 최대 100), current_level(int)
> - Signal: score_changed, health_changed, game_over, level_changed
> - 함수: add_score(amount), take_damage(amount), heal(amount), next_level()
> - game_over는 health가 0 이하일 때 자동 발생"

### 실습 11-2: 씬 전환 시스템
Claude에게 다음 요청:

> "Godot 4에서 씬 전환 시스템을 만들어줘.
> - 메인 메뉴 씬: `res://scenes/ui/main_menu.tscn`
> - 게임 씬: `res://scenes/level1.tscn`
> - 게임오버 씬: `res://scenes/ui/game_over.tscn`
> - 메인 메뉴에 'Start Game' 버튼 → level1으로 전환
> - GameManager의 game_over Signal → game_over 씬으로 자동 전환
> - 게임오버 화면에 최종 스코어 표시, 'Retry' 버튼
> - 씬 전환 시 페이드 인/아웃 효과 추가"

---

## 확인 포인트
- [ ] Autoload가 왜 필요한지 안다 (씬 전환 후에도 데이터 유지)
- [ ] `get_tree().change_scene_to_file()`로 씬을 바꿀 수 있다
- [ ] `get_tree().paused`로 게임을 멈출 수 있다
- [ ] Signal 기반 아키텍처의 장점을 안다 (결합도 낮춤)

## 다음 챕터
[Ch12 — UI / HUD](./ch12_ui_hud.md)
