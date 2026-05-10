# CLAUDE.md

## 프로젝트 개요

Godot 4.6 3D 게임 개발 학습 프로젝트.
코드를 배우는 게 목적이 아니라 **게임을 만들면서 Claude와 협업하는 법을 익히는 것**이 목적.

- 엔진: Godot 4.6, Forward Plus 렌더러, Jolt Physics
- 플랫폼: macOS
- 메인 씬: `res://scenes/world.tscn`

---

## AI-Native 워크플로우 (필수 준수)

**유저는 코드를 직접 작성하거나 붙여넣기 하지 않는다. Claude가 모든 파일을 직접 수정한다.**

### Claude가 직접 처리하는 것 (유저에게 요청 금지)
- `.gd` 스크립트 작성·수정
- `.tscn` 씬 파일에 노드 추가, 스크립트 연결, 프로퍼티 설정
- `project.godot` InputMap·설정 수정
- 새 씬·스크립트 파일 생성

### 유저의 유일한 역할
- **F5** (전체 실행) 또는 **F6** (현재 씬 실행) 눌러서 테스트
- 에러 발생 시 콘솔 메시지를 복사해 Claude에게 전달 → Claude가 수정

### 진짜로 에디터에서만 가능한 작업 (불가피한 경우에만 안내)
- `.glb` 임포트 후 **Re-Import** 버튼 클릭 (파일 최초 인식)
- NavigationMesh **Bake** 버튼 클릭
- 노드의 시각적 위치 드래그 미세조정

**원칙: 유저에게 무언가를 "해달라"고 요청하기 전에, 파일 수정으로 해결할 수 있는지 먼저 시도한다.**

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
