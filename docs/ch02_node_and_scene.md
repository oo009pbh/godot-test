# Ch02 — 노드 & 씬 시스템

---

## 개념

### Node란?
Godot에서 모든 게임 오브젝트는 **Node**다.

- 이름이 있다 (`Player`, `Camera3D`, `Ground` 등)
- 부모/자식 관계로 트리 구조를 이룬다
- 스크립트(`.gd`)를 붙이면 동작을 추가할 수 있다
- `_ready()`, `_process()` 같은 라이프사이클 함수가 있다

### 자주 쓰는 3D Node

| Node | 역할 |
|------|------|
| `Node3D` | 3D 공간의 기본 컨테이너 (위치/회전/크기 보유) |
| `MeshInstance3D` | 3D 모양을 화면에 표시 |
| `Camera3D` | 플레이어 시점 |
| `DirectionalLight3D` | 태양광 (방향 있는 조명) |
| `CharacterBody3D` | 물리 기반 캐릭터 (플레이어, 적) |
| `StaticBody3D` | 고정된 물체 (바닥, 벽) |
| `CollisionShape3D` | 충돌 범위 (Body에 항상 붙임) |
| `Area3D` | 트리거 영역 (아이템 획득, 데미지 존) |

### Node Tree 예시
```
World (Node3D)                ← 씬의 루트
├── DirectionalLight3D        ← 태양
├── Ground (StaticBody3D)     ← 바닥
│   ├── MeshInstance3D        ← 바닥 모양
│   └── CollisionShape3D      ← 바닥 충돌 범위
└── Player (CharacterBody3D)  ← 플레이어
    ├── MeshInstance3D        ← 플레이어 모양
    ├── CollisionShape3D      ← 플레이어 충돌 범위
    └── Camera3D              ← 플레이어 카메라
```

부모 Node가 움직이면 자식 Node들도 같이 움직인다.
→ Player가 이동하면 Camera3D도 함께 이동한다.

### Signal (신호)
"어떤 일이 일어났을 때" 다른 곳에 알리는 시스템.

```
예: Area3D에 Player가 들어옴
    → Area3D가 "body_entered" Signal 발생
    → 연결된 함수가 호출됨 (아이템 획득 처리 등)
```

### Scene 인스턴싱
씬 파일(`.tscn`)을 다른 씬에서 재사용하는 것.

```
Enemy.tscn (설계도 1개)
    → Level 씬에 10개 배치 = 10개의 인스턴스
    → Enemy.tscn 수정 → 모든 인스턴스에 자동 반영
```

---

## 실습: 첫 3D 씬 실행해보기

Claude가 기본 3D 씬 파일을 직접 만들어준다.
다음과 같이 요청하면 된다:

> "Godot 4로 바닥 위에 박스가 있고, 카메라로 볼 수 있는 기본 3D 씬을 만들어줘.
> StaticBody3D 바닥, MeshInstance3D 박스, Camera3D를 포함해줘."

Claude가 `scenes/world.tscn`과 필요한 스크립트를 생성하면
Godot 에디터에서 F6으로 실행한다.

---

## 확인 포인트
- [ ] Node와 Scene의 차이를 말할 수 있다
- [ ] 부모-자식 관계가 왜 중요한지 안다 (같이 움직임)
- [ ] CharacterBody3D와 StaticBody3D의 차이를 안다
- [ ] Signal이 어떤 상황에 쓰이는지 안다

## 다음 챕터
[Ch03 — GDScript 독해력](./ch03_gdscript_reading.md)
