# Godot 4 3D 게임 개발 학습 프로젝트

Godot 4로 3D 게임을 만들면서 **Claude와 협업하는 법**을 익히는 학습용 레포지토리.

코드를 직접 작성하는 게 목표가 아니라, AI에게 정확히 지시하고 결과를 이해하는 워크플로우를 체득하는 것이 목표.

---

## 환경

- 엔진: Godot 4.6, Forward Plus 렌더러, Jolt Physics
- 플랫폼: macOS

---

## 학습 방식 (AI-Native 워크플로우)

```
1. 챕터 개념 문서 읽기 (docs/ 폴더)
2. Claude에게 "만들어줘" 요청
3. Godot 에디터에서 Cmd+R (현재 씬 실행) 또는 Cmd+B (메인 씬 실행)
4. 결과 확인, 에러 발생 시 콘솔 메시지를 Claude에게 전달
5. Claude가 파일 수정 → 다시 실행
6. 동작 확인 후 "왜 이렇게 됐지?" 질문 → 개념 이해
```

코드를 손으로 짜거나 붙여넣지 않는다. Claude가 모든 파일을 직접 작성/수정한다.

---

## 커리큘럼 (17챕터)

### Phase 1 — Godot 구조 이해

| # | 챕터 | 핵심 개념 | 상태 |
|---|------|----------|------|
| 1 | [에디터 & 프로젝트 구조](docs/ch01_editor_and_project.md) | Scene, Node, 에디터 레이아웃 | ✅ |
| 2 | [노드 & 씬 시스템](docs/ch02_node_and_scene.md) | Node Tree, Instance, Signal | ✅ |
| 3 | [GDScript 독해력](docs/ch03_gdscript_reading.md) | 변수, 함수, 라이프사이클 | 🔄 |
| 4 | [Claude에게 잘 지시하는 법](docs/ch04_directing_ai.md) | 요구사항 전달, 에러 디버그 | |

### Phase 2 — 3D 공간 기초

| # | 챕터 | 핵심 개념 |
|---|------|----------|
| 5 | [3D 좌표계와 Transform](docs/ch05_3d_coordinates.md) | Vector3, 위치/회전/크기 |
| 6 | [카메라와 조명](docs/ch06_camera_and_lighting.md) | Camera3D, Light, Environment |
| 7 | [3D 물리 & 충돌](docs/ch07_3d_physics.md) | CharacterBody3D, CollisionShape3D |
| 8 | [3D 애셋 가져오기](docs/ch08_3d_assets.md) | .glb 임포트, Material, MeshInstance3D |

### Phase 3 — 게임플레이 시스템

| # | 챕터 | 핵심 개념 |
|---|------|----------|
| 9 | [플레이어 컨트롤러](docs/ch09_player_controller.md) | Input, move_and_slide, 카메라 Rig |
| 10 | [적 AI & 내비게이션](docs/ch10_enemy_ai.md) | NavigationAgent3D, State Machine |
| 11 | [게임 상태 관리](docs/ch11_game_state.md) | Autoload, GameManager, SceneTree |
| 12 | [UI / HUD](docs/ch12_ui_hud.md) | Control, CanvasLayer, Signal |

### Phase 4 — 완성도

| # | 챕터 | 핵심 개념 |
|---|------|----------|
| 13 | [파티클 & VFX](docs/ch13_vfx.md) | GPUParticles3D, AnimationPlayer |
| 14 | [오디오](docs/ch14_audio.md) | AudioStreamPlayer3D, Bus |
| 15 | [씬 전환 & 세이브](docs/ch15_scene_save.md) | PackedScene, ResourceSaver |
| 16 | [빌드 & 배포](docs/ch16_export.md) | Export Template, 플랫폼 |

### Phase 5 — 미니 프로젝트

| # | 챕터 | 내용 |
|---|------|-----|
| 17 | [3인칭 어드벤처 (종합)](docs/ch17_mini_project.md) | 전체 시스템 통합 |

---

## 프로젝트 구조

```
├── scenes/          # Godot 씬 파일 (.tscn)
├── scripts/         # GDScript 파일 (.gd)
├── docs/            # 챕터별 학습 문서
├── qna/             # 챕터 진행 중 생긴 Q&A 정리
└── project.godot    # Godot 프로젝트 설정
```
