# CLAUDE.md

## 프로젝트 개요

Godot 4.6 3D 게임 개발 학습 프로젝트.
코드를 배우는 게 목적이 아니라 **게임을 만들면서 Claude와 협업하는 법을 익히는 것**이 목적.

- 엔진: Godot 4.6, Forward Plus 렌더러, Jolt Physics
- 플랫폼: macOS
- 메인 씬: `res://scenes/world.tscn`

---

## AI-Native 워크플로우 (필수 준수)

**유저는 코드를 직접 작성하거나 붙여넣기 하지 않는다.**

- 스크립트, 씬 파일 등 모든 파일을 Claude가 직접 Write/Edit 툴로 작성한다
- 코드 블록을 제시하고 "붙여넣어보세요"라고 하지 않는다
- 유저는 Godot 에디터에서 **F5 (전체 실행) 또는 F6 (현재 씬 실행)** 만 누르면 된다
- 에러 발생 시 유저가 에디터 콘솔에서 메시지를 복사해 Claude에게 전달 → Claude가 파일 수정

에디터에서만 가능한 작업은 명확히 안내:
- 3D 모델(.glb) 임포트 설정
- NavigationMesh Bake
- 노드 시각적 위치 미세조정

---

## 프로젝트 구조

```
새-게임-프로젝트/
├── project.godot          # 프로젝트 설정
├── scenes/
│   └── world.tscn         # 메인 씬 (World > Ground + Player + Light)
├── scripts/
│   └── player.gd          # 플레이어 이동 스크립트
├── docs/                  # 학습 커리큘럼 (17챕터)
│   ├── learning_roadmap.md
│   ├── ch01_editor_and_project.md
│   ├── ch02_node_and_scene.md
│   ├── ch03_gdscript_reading.md
│   └── ... (ch04 ~ ch17)
└── CLAUDE.md
```

---

## 현재 구현 상태

### world.tscn 씬 구조
```
World (Node3D)
├── DirectionalLight3D    # 방향광, 그림자 활성화
├── Ground (StaticBody3D) # 20×20 회색 바닥
│   ├── MeshInstance3D    # PlaneMesh
│   └── CollisionShape3D  # WorldBoundaryShape3D
└── Player (CharacterBody3D)  # scripts/player.gd 부착
    ├── MeshInstance3D    # CapsuleMesh (파란색)
    ├── CollisionShape3D  # CapsuleShape3D
    └── Camera3D          # 플레이어 자식으로 부착
```

### scripts/player.gd 기능
- 방향키(ui_left/right/up/down)로 XZ 평면 이동
- 스페이스바(ui_accept)로 점프
- 중력(9.8) 적용, `move_and_slide()` 사용
- `@export var speed: float = 5.0` — Inspector에서 조절 가능

---

## .tscn 파일 작성 규칙

외부 스크립트 연결 시 반드시 `[ext_resource]` 선언 후 참조:

```
[ext_resource type="Script" path="res://scripts/player.gd" id="Script_player"]

[node name="Player" type="CharacterBody3D" parent="."]
script = ExtResource("Script_player")   # 직접 경로 문자열 사용 금지
```

Godot 에디터가 저장할 때 `uid="uid://..."` 를 자동으로 추가함 — 직접 작성 불필요.

---

## GDScript 주요 주의사항

- 문자열 보간: `"${delta}"` 문법 없음 → `str(delta)` 또는 `"값: %s" % delta` 사용
- 들여쓰기: 탭(Tab) 사용 (스페이스 혼용 금지)
- `CharacterBody3D` 이동은 반드시 `_physics_process` 안에서 `move_and_slide()` 호출
- `$Camera3D` 같은 노드 참조는 `_ready()` 이후에만 안전

---

## 학습 커리큘럼 진행 상황

| Phase | 챕터 | 상태 |
|-------|------|------|
| 1 | Ch01 에디터 & 프로젝트 구조 | ✅ 완료 |
| 1 | Ch02 노드 & 씬 시스템 | ✅ 완료 |
| 1 | Ch03 GDScript 독해력 | 🔄 진행 중 (실습 3-2 미완) |
| 1 | Ch04 ~ Phase 5 | 미시작 |
