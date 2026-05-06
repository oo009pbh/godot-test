# Ch15 — 씬 전환 & 세이브/불러오기

> 게임을 끄고 나서도 진행 상황이 유지되려면 데이터를 파일로 저장해야 한다.
> 씬 전환을 자연스럽게 만드는 방법과 세이브 시스템을 이해한다.

---

## 개념

### 씬 전환 패턴

**즉시 전환 (딱딱하지만 간단):**
```gdscript
get_tree().change_scene_to_file("res://scenes/level2.tscn")
```

**페이드 인/아웃 전환 (자연스러움):**

CanvasLayer에 검은 ColorRect(Full Rect)를 두고 투명도를 조절:
```gdscript
# transition_manager.gd (Autoload)
extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
    fade_rect.modulate.a = 0.0  # 시작은 투명

func transition_to(scene_path: String, fade_time: float = 0.4) -> void:
    # 페이드 아웃 (투명 → 검은색)
    var tween = create_tween()
    tween.tween_property(fade_rect, "modulate:a", 1.0, fade_time)
    await tween.finished

    # 씬 전환
    get_tree().change_scene_to_file(scene_path)

    # 페이드 인 (검은색 → 투명)
    tween = create_tween()
    tween.tween_property(fade_rect, "modulate:a", 0.0, fade_time)
```

**어디서든 호출:**
```gdscript
# TransitionManager가 Autoload로 등록되어 있다면
TransitionManager.transition_to("res://scenes/level2.tscn")
```

---

### res:// vs user:// — 경로 차이

| 경로 | 위치 | 읽기 | 쓰기 | 용도 |
|------|------|------|------|------|
| `res://` | 게임 설치 폴더 | O | X (빌드 후) | 게임 파일, 씬, 스크립트 |
| `user://` | 사용자 데이터 폴더 | O | O | 세이브 파일, 설정, 스크린샷 |

**user:// 실제 경로:**
- macOS: `~/Library/Application Support/Godot/app_userdata/[프로젝트명]/`
- Windows: `%APPDATA%/Godot/app_userdata/[프로젝트명]/`
- Linux: `~/.local/share/godot/app_userdata/[프로젝트명]/`

**왜 res://에 세이브 파일을 쓸 수 없는가?**
배포된 게임은 패키징되어 있어서 res:// 안에 새 파일을 만들 수 없다.
사용자 데이터는 반드시 user://에 저장해야 한다.

---

### 세이브 데이터 시스템 (JSON)

**왜 JSON인가?**
- 사람이 읽을 수 있는 텍스트 형식
- GDScript Dictionary와 바로 변환 가능
- 다른 툴로도 편집 가능 (디버깅 편함)

```gdscript
# res://scripts/save_manager.gd (Autoload)
extends Node

const SAVE_PATH = "user://save.json"

func save() -> void:
    var save_data = {
        "score": GameManager.score,
        "health": GameManager.health,
        "level": GameManager.current_level,
        "position": {
            "x": _get_player().global_position.x,
            "y": _get_player().global_position.y,
            "z": _get_player().global_position.z
        },
        "timestamp": Time.get_unix_time_from_system()  # 저장 시각
    }

    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data, "\t"))  # 들여쓰기 포함
        file.close()
        print("게임 저장 완료")
    else:
        push_error("세이브 파일을 열 수 없습니다: " + SAVE_PATH)

func load_save() -> bool:
    if not has_save():
        return false

    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if not file:
        return false

    var json_text = file.get_as_text()
    file.close()

    var save_data = JSON.parse_string(json_text)
    if save_data == null:
        push_error("세이브 파일 파싱 실패")
        return false

    # 데이터 복원
    GameManager.score = save_data.get("score", 0)
    GameManager.health = save_data.get("health", 100)
    GameManager.current_level = save_data.get("level", 1)

    return true

func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
    if has_save():
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
        print("세이브 파일 삭제")

func _get_player() -> Node:
    return get_tree().get_first_node_in_group("player")
```

---

### 세이브 데이터 보안

**일반 게임:** JSON 평문으로 충분.
**경쟁 게임 / 리더보드:** 조작 방지가 필요하면 해시로 무결성 검증:

```gdscript
func _create_checksum(data: Dictionary) -> String:
    var raw = JSON.stringify(data)
    return raw.sha256_text()  # 간단한 무결성 체크

func save() -> void:
    var save_data = { ... }
    save_data["checksum"] = _create_checksum(save_data)
    # 파일 저장...

func load_save() -> bool:
    # 파일 읽기 후...
    var checksum = save_data.get("checksum", "")
    save_data.erase("checksum")
    if _create_checksum(save_data) != checksum:
        push_error("세이브 파일이 변조되었습니다")
        return false
    # 데이터 복원...
```

---

### PackedScene — 런타임에 씬 생성

**비유: 3D 프린터**
설계도(PackedScene)를 넣으면 원하는 만큼 출력물(인스턴스)을 만들어낸다.

```gdscript
# @export로 Inspector에서 씬 파일 연결
@export var enemy_scene: PackedScene
@export var coin_scene: PackedScene

# 런타임에 인스턴스 생성
func spawn_enemy(at_position: Vector3) -> void:
    var enemy = enemy_scene.instantiate()   # 설계도에서 인스턴스 생성
    get_tree().current_scene.add_child(enemy)  # 씬에 추가
    enemy.global_position = at_position     # 위치 설정

# 발사체처럼 자주 생성/삭제하는 오브젝트
func fire_bullet() -> void:
    var bullet = bullet_scene.instantiate()
    get_parent().add_child(bullet)          # 부모에 추가 (플레이어의 형제로)
    bullet.global_position = $Muzzle.global_position
    bullet.direction = -global_transform.basis.z  # 총구 방향
```

**주의:** `add_child()`를 자기 자신에게 하면 안 된다.
부모 씬(`get_parent()` 또는 `get_tree().current_scene`)에 추가해야 한다.

---

### Spawner 패턴 — 주기적 스폰 시스템

```gdscript
# res://scripts/spawner.gd
extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 3.0    # 스폰 간격 (초)
@export var max_enemies: int = 5           # 최대 적 수

var spawn_timer: float = 0.0

func _physics_process(delta: float) -> void:
    spawn_timer -= delta
    if spawn_timer <= 0.0:
        spawn_timer = spawn_interval
        _try_spawn()

func _try_spawn() -> void:
    # 현재 적 수 확인
    var current_enemies = get_tree().get_nodes_in_group("enemy").size()
    if current_enemies >= max_enemies:
        return

    # 자식 Node3D들 중 랜덤 위치에 스폰
    var spawn_points = get_children()
    if spawn_points.is_empty():
        return

    var point = spawn_points.pick_random()  # 랜덤 스폰 포인트
    var enemy = enemy_scene.instantiate()
    get_tree().current_scene.add_child(enemy)
    enemy.global_position = point.global_position
```

---

### 레벨 데이터 JSON으로 관리

하드코딩 대신 외부 파일로 레벨 설정을 관리하면 디자인 변경이 쉽다:

```json
// res://data/levels/level1.json
{
    "name": "Forest",
    "enemy_count": 5,
    "spawn_interval": 3.0,
    "spawn_points": [
        [10, 0, 10],
        [-10, 0, 10],
        [0, 0, -10]
    ],
    "coin_positions": [
        [3, 0.5, 3],
        [-3, 0.5, 5]
    ],
    "bgm": "res://assets/audio/forest_bgm.ogg",
    "time_limit": 180
}
```

```gdscript
# 레벨 데이터 불러오기
func load_level_data(level_num: int) -> Dictionary:
    var path = "res://data/levels/level%d.json" % level_num
    var file = FileAccess.open(path, FileAccess.READ)
    if not file:
        return {}
    var data = JSON.parse_string(file.get_as_text())
    file.close()
    return data

# 사용
func _ready() -> void:
    var data = load_level_data(GameManager.current_level)
    AudioManager.play_bgm(load(data["bgm"]))
    for pos_array in data["spawn_points"]:
        var pos = Vector3(pos_array[0], pos_array[1], pos_array[2])
        spawn_enemy(pos)
```

---

## 실습

### 실습 15-1: 세이브/불러오기 시스템
Claude에게 다음 요청:

> "Godot 4에서 세이브/불러오기 시스템을 만들어줘.
> - `res://scripts/save_manager.gd` (Autoload: 'SaveManager')
> - 저장 데이터: score, health, current_level, player_position(x,y,z), timestamp
> - `save()`: user://save.json에 JSON으로 저장 (들여쓰기 포함)
> - `load_save()`: 파일 있으면 불러와서 GameManager에 적용, 없으면 false 반환
> - `has_save()`: 파일 존재 여부 확인
> - `delete_save()`: 파일 삭제
> - 간단한 체크섬으로 파일 변조 감지
> - project.godot Autoload에 SaveManager 등록
> - 메인 메뉴에 'Continue' 버튼 추가 (has_save()가 true일 때만 활성화)"

### 실습 15-2: Spawner 시스템
Claude에게 다음 요청:

> "Godot 4에서 레벨에 적을 동적으로 스폰하는 시스템을 만들어줘.
> - `res://scenes/spawner.tscn`, `res://scripts/spawner.gd`
> - @export: enemy_scene(PackedScene), spawn_interval(float 기본 3.0), max_enemies(int 기본 5)
> - 자식 Node3D들의 위치 중 랜덤으로 선택해서 스폰
> - 현재 'enemy' 그룹의 적 수가 max_enemies 미만일 때만 스폰
> - level1.tscn에 Spawner를 3곳에 배치해줘 (맵 가장자리)
> - 각 Spawner에 SpawnPoint 자식 Node3D를 2~3개씩 배치"

### 실습 15-3: 페이드 씬 전환 Autoload
Claude에게 다음 요청:

> "Godot 4에서 페이드 인/아웃 씬 전환 Autoload를 만들어줘.
> - `res://scripts/transition_manager.gd` (Autoload: 'TransitionManager')
> - CanvasLayer(layer=128) + 검은 ColorRect(Full Rect)로 구성
> - `transition_to(scene_path: String, fade_time: float = 0.4)`: 페이드 아웃 → 전환 → 페이드 인
> - 전환 중 입력 무시 (is_transitioning 플래그)
> - project.godot에 Autoload 등록
> - 기존 씬 전환 코드(change_scene_to_file 직접 호출)를 TransitionManager.transition_to()로 교체"

---

## 확인 포인트
- [ ] `res://`와 `user://`의 차이를 안다 (설치 폴더 vs 사용자 데이터)
- [ ] `user://`의 실제 저장 경로를 안다 (OS별)
- [ ] `FileAccess.open()`으로 파일을 열고 닫는 패턴을 안다
- [ ] `PackedScene.instantiate()`로 동적으로 오브젝트를 생성할 수 있다
- [ ] 인스턴스를 `add_child()`할 때 자기 자신이 아닌 부모/씬에 추가해야 하는 이유를 안다
- [ ] 페이드 전환에서 `await tween.finished`가 왜 필요한지 안다
- [ ] 레벨 데이터를 JSON으로 분리하면 좋은 이유를 안다 (코드 수정 없이 디자인 변경 가능)

## 다음 챕터
[Ch16 — 빌드 & 배포](./ch16_export.md)
