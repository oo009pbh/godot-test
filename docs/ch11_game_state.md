# Ch11 — 게임 상태 관리

> 게임이 커질수록 "점수", "체력", "현재 레벨" 같은 데이터를 여러 씬이 공유해야 한다.
> 씬이 바뀌면 모든 노드가 사라지는데, 데이터를 어떻게 유지하는지가 이 챕터의 핵심이다.

---

## 개념

### 왜 게임 상태 관리가 필요한가

**문제 상황:**
- 플레이어가 레벨 1에서 코인 50개를 모음 → 레벨 2로 씬 전환
- 레벨 2 씬이 로드되면 레벨 1의 모든 노드가 사라짐
- 점수 50이 저장된 Node도 사라져서 점수가 0으로 초기화됨

**해결책:** 씬이 바뀌어도 살아남는 별도의 "창고"가 필요하다 → **Autoload**

---

### Autoload — 전역 싱글톤

**비유: 건물 안내데스크**
건물 어느 방에서든 안내데스크에 전화할 수 있듯,
Autoload는 어떤 씬에서든 접근 가능한 전역 스크립트다.
씬이 바뀌어도 Autoload는 계속 살아있다.

**등록 방법:**
1. `Project → Project Settings → Autoload` 탭
2. Script Path에 `res://scripts/game_manager.gd` 입력
3. Node Name을 `GameManager`로 설정
4. Add 클릭

등록 후에는 **어느 씬에서든** `GameManager.함수()` 또는 `GameManager.변수`로 접근 가능.

```gdscript
# res://scripts/game_manager.gd
extends Node

# --- 게임 데이터 ---
var score: int = 0
var health: int = 100
var current_level: int = 1

# --- Signal 선언 (HUD가 이 신호를 받아서 화면을 업데이트) ---
signal score_changed(new_score: int)
signal health_changed(new_health: int)
signal game_over
signal level_changed(new_level: int)

# --- 점수 관련 ---
func add_score(amount: int) -> void:
    score += amount
    score_changed.emit(score)   # HUD에 알림

# --- 체력 관련 ---
func take_damage(amount: int) -> void:
    health -= amount
    health = max(0, health)       # 0 아래로 내려가지 않게
    health_changed.emit(health)
    if health <= 0:
        game_over.emit()

func heal(amount: int) -> void:
    health = min(100, health + amount)  # 100 초과하지 않게
    health_changed.emit(health)

# --- 레벨 관련 ---
func next_level() -> void:
    current_level += 1
    level_changed.emit(current_level)
    get_tree().change_scene_to_file("res://scenes/level%d.tscn" % current_level)

# --- 초기화 (게임 재시작 시) ---
func reset() -> void:
    score = 0
    health = 100
    current_level = 1
```

**다른 스크립트에서 접근:**
```gdscript
# 어디서든 바로 사용 가능
GameManager.add_score(100)
GameManager.take_damage(20)
var current_health = GameManager.health
```

---

### SceneTree — 씬 전환과 게임 흐름 제어

`get_tree()`로 SceneTree에 접근해서 씬 전환, 일시정지, 게임 종료를 처리한다.

```gdscript
# 씬 전환
get_tree().change_scene_to_file("res://scenes/level2.tscn")

# 씬 다시 로드 (재시작 — 현재 씬을 처음부터 다시)
get_tree().reload_current_scene()

# 게임 종료
get_tree().quit()

# 일시정지 / 해제
get_tree().paused = true
get_tree().paused = false
```

---

### 씬 전환 시 데이터 유지

씬이 바뀌면 모든 Node가 사라진다. 데이터를 유지하려면:

**방법 1: Autoload에 저장 (권장)**
```gdscript
# 씬 전환 전 — 현재 씬의 스크립트에서
GameManager.score = current_score   # Autoload에 저장

# 새 씬에서 — 새 씬의 _ready()에서
var score = GameManager.score       # 읽어서 사용
```

**방법 2: 세이브 파일 (Ch15 참고)**
게임을 완전히 종료하고 다시 켜도 유지해야 한다면 파일로 저장.

---

### 페이드 인/아웃 씬 전환

딱딱한 즉시 전환 대신 자연스럽게 화면을 어둡게 했다가 새 씬을 보여주는 패턴:

```gdscript
# Autoload(GameManager)에 전환 함수를 두면 어디서든 호출 가능
@onready var fade_rect: ColorRect = $FadeRect  # 검은 ColorRect (전체 화면 크기)

func transition_to(scene_path: String) -> void:
    # 1. 페이드 아웃 (투명 → 검은색, 0.4초)
    var tween = create_tween()
    tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
    await tween.finished    # 페이드 아웃이 끝날 때까지 기다림

    # 2. 씬 전환
    get_tree().change_scene_to_file(scene_path)

    # 3. 새 씬에서 페이드 인 (검은색 → 투명, 0.4초)
    tween = create_tween()
    tween.tween_property(fade_rect, "modulate:a", 0.0, 0.4)
```

`await`는 **비동기 대기**다. `tween.finished` 신호가 올 때까지 이 함수가 여기서 잠시 멈춘다.
다른 함수나 물리 처리는 계속 진행되고, 트윈이 끝나면 다음 줄로 넘어간다.

---

### 일시정지 처리

```gdscript
# ESC로 일시정지 토글
func _input(event: InputEvent) -> void:
    if event.is_action_just_pressed("ui_cancel"):
        var is_paused = !get_tree().paused
        get_tree().paused = is_paused
        $PauseMenu.visible = is_paused
```

**일시정지 중 Process Mode 문제:**
`get_tree().paused = true`로 멈추면 **모든 노드**가 멈춘다.
일시정지 메뉴의 버튼도 반응이 없어진다!

해결책: 일시정지 중에도 동작해야 하는 노드의 `Process Mode`를 **Always**로 설정.

```
Inspector → Node → Process Mode → Always
```

| Process Mode | 동작 |
|--------------|------|
| `Inherit` | 부모 설정 따름 (기본값) |
| `Pausable` | 일시정지 시 멈춤 |
| `When Paused` | 일시정지 중에만 동작 |
| `Always` | 항상 동작 |
| `Disabled` | 항상 멈춤 |

**팁:** 일시정지 메뉴 UI는 `Always`, 적/플레이어는 기본값(`Pausable`)으로 두면 된다.

---

### Timer — 지연 실행

특정 동작을 일정 시간 후에 실행할 때 사용.

```gdscript
# 코드에서 일회성 타이머 만들기
func die() -> void:
    is_dead = true
    # 2초 후 씬에서 제거
    await get_tree().create_timer(2.0).timeout
    queue_free()

# Timer 노드를 씬에 배치한 경우
@onready var attack_timer: Timer = $AttackTimer

func _ready() -> void:
    attack_timer.wait_time = 1.5
    attack_timer.timeout.connect(_on_attack_timer_timeout)

func _on_attack_timer_timeout() -> void:
    attack()
```

**`create_timer()`와 `Timer` 노드의 차이:**
- `create_timer()`: 코드에서 임시로 한 번 사용. 간단한 지연 처리에 적합.
- `Timer` 노드: 반복 실행, Inspector에서 설정 가능. 주기적 이벤트에 적합.

---

### Signal 기반 아키텍처

**왜 Signal을 쓰는가?**
직접 참조 방식:
```gdscript
# Enemy가 HUD를 직접 참조 (강한 결합)
$"../HUD".update_score(score)  # HUD가 없으면 에러!
```

Signal 방식:
```gdscript
# Enemy → GameManager → HUD (느슨한 결합)
GameManager.add_score(100)    # GameManager가 score_changed Signal을 발생
# HUD는 그 Signal을 구독해서 알아서 업데이트
```

**Signal이 게임 아키텍처를 유연하게 만드는 이유:**
- HUD가 없어도 Enemy 코드가 작동함
- HUD를 수정해도 Enemy 코드를 건드릴 필요 없음
- 나중에 Score 관련 기능을 추가하기 쉬움 (Signal 구독자만 추가하면 됨)

**실제 데이터 흐름:**
```
적(Enemy) 처치
    ↓
enemy.health_depleted Signal 발생
    ↓
GameManager._on_enemy_died() 호출
    ↓
GameManager.add_score(100)
    ↓
GameManager.score_changed Signal 발생
    ↓
HUD._on_score_changed(new_score) 호출
    ↓
HUD의 ScoreLabel 텍스트 업데이트
```

```gdscript
# enemy.gd
signal health_depleted

func take_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        health_depleted.emit()
        queue_free()

# game_manager.gd (_ready에서 적 인스턴스에 연결)
func register_enemy(enemy: Node) -> void:
    enemy.health_depleted.connect(_on_enemy_died)

func _on_enemy_died() -> void:
    add_score(100)
```

---

## 실습

### 실습 11-1: GameManager Autoload
Claude에게 다음 요청:

> "Godot 4에서 GameManager Autoload를 만들어줘.
> - `res://scripts/game_manager.gd`
> - project.godot Autoload에 'GameManager'로 등록해줘
> - 관리할 데이터: score(int), health(int 최대 100), current_level(int)
> - Signal: score_changed(new_score), health_changed(new_health), game_over, level_changed(new_level)
> - 함수: add_score(amount), take_damage(amount), heal(amount), next_level(), reset()
> - health가 0 이하면 game_over Signal 자동 발생
> - heal()은 100 초과 불가, take_damage()는 0 미만 불가"

### 실습 11-2: 씬 전환 시스템
Claude에게 다음 요청:

> "Godot 4에서 씬 전환 시스템을 만들어줘.
> - 메인 메뉴 씬: `res://scenes/ui/main_menu.tscn`
> - 게임 씬: `res://scenes/level1.tscn`
> - 게임오버 씬: `res://scenes/ui/game_over.tscn`
> - 메인 메뉴에 'Start Game' 버튼 → level1으로 페이드 전환
> - GameManager의 game_over Signal → game_over 씬으로 자동 전환
> - 게임오버 화면에 최종 스코어 표시, 'Retry' 버튼 (GameManager.reset() 후 level1로)
> - 씬 전환에 0.4초 페이드 인/아웃 효과 추가
> - project.godot 메인 씬을 main_menu.tscn으로 설정"

### 실습 11-3: 일시정지 시스템
Claude에게 다음 요청:

> "Godot 4에서 ESC로 열리는 일시정지 시스템을 만들어줘.
> - 일시정지 메뉴: `res://scenes/ui/pause_menu.tscn`
> - 반투명 검은 배경 (ColorRect, alpha 0.7)
> - 'Resume', 'Restart', 'Main Menu', 'Quit' 버튼 세로 정렬
> - 이 메뉴의 Process Mode는 Always로 설정
> - player.gd에서 ESC 입력 처리: get_tree().paused 토글
> - 일시정지 중에는 마우스 커서 보이게 (Input.MOUSE_MODE_VISIBLE)"

---

## 확인 포인트
- [ ] Autoload가 씬이 바뀌어도 살아남는 이유를 안다 (씬 트리의 루트에 등록됨)
- [ ] `get_tree().change_scene_to_file()`로 씬을 바꿀 수 있다
- [ ] `get_tree().paused`로 게임을 멈출 때 Process Mode 설정이 필요한 이유를 안다
- [ ] `await tween.finished`가 비동기 대기임을 안다
- [ ] `create_timer()`와 Timer 노드의 차이를 안다
- [ ] Signal 기반 아키텍처가 직접 참조보다 유연한 이유를 안다

## 다음 챕터
[Ch12 — UI / HUD](./ch12_ui_hud.md)
