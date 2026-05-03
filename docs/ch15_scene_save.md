# Ch15 — 씬 전환 & 세이브/불러오기

---

## 개념

### 씬 전환 패턴

**즉시 전환:**
```gdscript
get_tree().change_scene_to_file("res://scenes/level2.tscn")
```

**페이드 인/아웃 전환:**
```gdscript
# 페이드 아웃 → 씬 전환 → 페이드 인
func transition_to(scene_path: String):
    var tween = create_tween()
    tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
    await tween.finished
    get_tree().change_scene_to_file(scene_path)
```

### 세이브 데이터 시스템

**JSON 방식 (간단, 텍스트):**
```gdscript
# 저장
func save_game():
    var save_data = {
        "score": GameManager.score,
        "health": GameManager.health,
        "level": GameManager.current_level,
        "position": {
            "x": player.position.x,
            "y": player.position.y,
            "z": player.position.z
        }
    }
    var file = FileAccess.open("user://save.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()

# 불러오기
func load_game():
    if not FileAccess.file_exists("user://save.json"):
        return  # 세이브 파일 없음

    var file = FileAccess.open("user://save.json", FileAccess.READ)
    var save_data = JSON.parse_string(file.get_as_text())
    file.close()

    GameManager.score = save_data["score"]
    GameManager.health = save_data["health"]
```

**`user://` 경로:**
- 사용자 데이터 디렉토리 (쓰기 가능)
- Windows: `%APPDATA%/Godot/app_userdata/[프로젝트명]/`
- Mac: `~/Library/Application Support/Godot/app_userdata/[프로젝트명]/`

### PackedScene — 런타임 씬 생성

```gdscript
# 씬 파일을 변수에 담기
@export var enemy_scene: PackedScene

# 런타임에 씬 인스턴스 생성
func spawn_enemy(at_position: Vector3):
    var enemy = enemy_scene.instantiate()
    enemy.position = at_position
    add_child(enemy)
```

**용도:** 스폰 포인트에서 적/아이템 동적 생성

### 레벨 디자인 데이터 분리
하드코딩 대신 JSON이나 Resource 파일로 레벨 데이터를 관리:

```json
// res://data/levels/level1.json
{
    "name": "Forest",
    "enemy_count": 5,
    "spawn_points": [[0,0,5], [3,0,8], [-2,0,10]],
    "bgm": "res://assets/audio/forest_bgm.ogg"
}
```

---

## 실습

### 실습 15-1: 자동 세이브 시스템
Claude에게 다음 요청:

> "Godot 4에서 세이브/불러오기 시스템을 만들어줘.
> - `res://scripts/save_manager.gd` (Autoload: 'SaveManager')
> - 저장 데이터: score, health, current_level, player_position
> - `save()`: `user://save.json`에 저장
> - `load_save()`: 불러오기. 세이브 없으면 기본값 반환
> - `has_save()`: 세이브 파일 존재 여부
> - 레벨 전환 시 자동 저장, 메인 메뉴에서 'Continue' 버튼으로 이어하기"

### 실습 15-2: 스폰 시스템
Claude에게 다음 요청:

> "Godot 4에서 레벨에 적을 동적으로 스폰하는 시스템을 만들어줘.
> - Spawner 씬: `res://scenes/spawner.tscn`
> - @export로 enemy_scene, spawn_interval(초), max_enemies 설정
> - 일정 시간마다 현재 적 수가 max_enemies 미만이면 스폰
> - 스폰 위치는 Spawner의 자식 Node3D들 위치 중 랜덤 선택"

---

## 확인 포인트
- [ ] `user://`와 `res://`의 차이를 안다 (읽기 전용 vs 쓰기 가능)
- [ ] `PackedScene.instantiate()`로 동적으로 오브젝트를 생성할 수 있다
- [ ] 세이브 파일이 어느 폴더에 저장되는지 안다

## 다음 챕터
[Ch16 — 빌드 & 배포](./ch16_export.md)
