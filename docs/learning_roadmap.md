# Godot 4 3D 게임 개발 커리큘럼 (AI-Native)

---

## 학습 워크플로우

```
1. 챕터 개념 읽기 (이 MD 파일들)
2. "만들어줘" → Claude가 프로젝트 파일을 직접 작성/수정
3. Godot 에디터에서 F5 또는 F6 눌러서 실행
4. 결과 확인 / 에러 발생 시 에러 메시지를 Claude에게 붙여넣기
5. Claude가 파일 수정 → 다시 F5
6. 동작 확인 후 "왜 이렇게 됐지?" 질문 → 개념 이해
```

> 코드를 손으로 짜거나 붙여넣을 필요 없음.
> 에러가 나는 경험 자체가 학습임. 에러 메시지를 무서워하지 않아도 됨.

---

## 목차

### Phase 1 — Godot 구조 이해 (실행 위주)
| # | 챕터 | 핵심 개념 |
|---|------|----------|
| 1 | [에디터 & 프로젝트 구조](./ch01_editor_and_project.md) | Scene, Node, 에디터 레이아웃 |
| 2 | [노드 & 씬 시스템](./ch02_node_and_scene.md) | Node Tree, Instance, Signal |
| 3 | [GDScript 독해력](./ch03_gdscript_reading.md) | 변수, 함수, 라이프사이클 |
| 4 | [Claude에게 잘 지시하는 법](./ch04_directing_ai.md) | 요구사항 전달, 에러 디버그 |

### Phase 2 — 3D 공간 기초
| # | 챕터 | 핵심 개념 |
|---|------|----------|
| 5 | [3D 좌표계와 Transform](./ch05_3d_coordinates.md) | Vector3, 위치/회전/크기 |
| 6 | [카메라와 조명](./ch06_camera_and_lighting.md) | Camera3D, Light, Environment |
| 7 | [3D 물리 & 충돌](./ch07_3d_physics.md) | CharacterBody3D, CollisionShape3D |
| 8 | [3D 애셋 가져오기](./ch08_3d_assets.md) | .glb 임포트, Material, MeshInstance3D |

### Phase 3 — 게임플레이 시스템
| # | 챕터 | 핵심 개념 |
|---|------|----------|
| 9 | [플레이어 컨트롤러](./ch09_player_controller.md) | Input, move_and_slide, 카메라 Rig |
| 10 | [적 AI & 내비게이션](./ch10_enemy_ai.md) | NavigationAgent3D, State Machine |
| 11 | [게임 상태 관리](./ch11_game_state.md) | Autoload, GameManager, SceneTree |
| 12 | [UI / HUD](./ch12_ui_hud.md) | Control, CanvasLayer, Signal |

### Phase 4 — 완성도
| # | 챕터 | 핵심 개념 |
|---|------|----------|
| 13 | [파티클 & VFX](./ch13_vfx.md) | GPUParticles3D, AnimationPlayer |
| 14 | [오디오](./ch14_audio.md) | AudioStreamPlayer3D, Bus |
| 15 | [씬 전환 & 세이브](./ch15_scene_save.md) | PackedScene, ResourceSaver |
| 16 | [빌드 & 배포](./ch16_export.md) | Export Template, 플랫폼 |

### Phase 5 — 미니 프로젝트
| # | 챕터 | 내용 |
|---|------|-----|
| 17 | [3인칭 어드벤처 (종합)](./ch17_mini_project.md) | 전체 시스템 통합 |

### Phase 6 — 아키텍처 & 리팩토링
| # | 챕터 | 핵심 개념 |
|---|------|----------|
| 18 | [게임 아키텍처 & 리팩토링](./ch18_architecture_refactoring.md) | Signal/Observer, 컴포넌트, 상태 머신, 함수형 스타일 |

---

## Godot 에디터에서 해야 할 것 (최소한)

Claude가 대부분의 파일을 직접 작성하지만, 에디터에서만 할 수 있는 것들이 있다:

| 작업 | 이유 |
|------|------|
| F5 / F6 실행 | 게임 실행 |
| 3D 모델 임포트 확인 | `.glb` 파일 임포트 설정은 에디터가 처리 |
| 노드 시각적 배치 조정 | 위치 미세 조정이 필요할 때 |
| 에러 메시지 복사 | 하단 콘솔에서 복사해서 Claude에게 전달 |

> 나머지는 모두 Claude가 직접 파일을 쓴다.
