# Ch17 — 미니 프로젝트: 3인칭 어드벤처 (종합)

> Phase 1~4의 모든 개념을 통합한 완성형 미니 게임을 만든다.
> 모든 파일은 Claude가 직접 생성/수정한다. 유저는 F5로 실행하고 결과를 확인만 한다.

---

## 게임 기획

**장르:** 3인칭 어드벤처
**목표:** 맵에 흩어진 코인 10개를 모두 모으면 클리어
**플레이 타임:** 약 2~3분

### 기능 목록
- [ ] WASD 이동 + 마우스 카메라 회전
- [ ] Space 점프
- [ ] 적 AI (플레이어 추격, 닿으면 데미지)
- [ ] 코인 수집 (Area3D + 애니메이션 + 파티클)
- [ ] 체력 시스템 (HUD 체력바)
- [ ] 점수/코인 카운터 (HUD 표시)
- [ ] 코인 모두 수집 → 클리어 씬 전환
- [ ] 체력 0 → 게임오버 씬 전환
- [ ] 페이드 인/아웃 씬 전환

### 씬 구조
```
res://scenes/
├── ui/
│   ├── main_menu.tscn
│   ├── hud.tscn
│   ├── pause_menu.tscn
│   ├── game_over.tscn
│   └── clear.tscn
├── effects/
│   └── explosion.tscn
├── items/
│   └── coin.tscn
├── player.tscn
├── enemy.tscn
└── level1.tscn        ← 메인 게임 씬

res://scripts/
├── game_manager.gd    (Autoload)
├── audio_manager.gd   (Autoload)
├── player.gd
├── enemy.gd
├── coin.gd
├── hud.gd
└── explosion.gd
```

---

## 단계별 제작 순서

### Step 1: Autoload 설정

Claude에게 요청:
> "Godot 4 미니 프로젝트의 GameManager Autoload를 만들어줘.
> `res://scripts/game_manager.gd`, Autoload 이름 'GameManager'
>
> 관리 데이터:
> - score: int = 0
> - health: int = 100
> - coin_count: int = 0  (현재 수집한 코인 수)
> - coin_total: int = 0  (레벨의 총 코인 수)
>
> Signal:
> - score_changed(new_score: int)
> - health_changed(new_health: int)
> - coin_collected(current: int, total: int)
> - game_over
> - level_clear
>
> 함수:
> - add_score(amount: int): score 증가, Signal 발생
> - take_damage(amount: int): health 감소, 0 이하면 game_over Signal
> - collect_coin(): coin_count 증가, coin_total과 같아지면 level_clear Signal
> - set_coin_total(total: int): 레벨 시작 시 총 코인 수 설정
> - reset(): 모든 값 초기화
>
> project.godot에 Autoload 등록도 해줘"

### Step 2: 레벨 기반 씬

Claude에게 요청:
> "Godot 4 3인칭 어드벤처의 레벨 씬을 만들어줘.
> `res://scenes/level1.tscn`
>
> - 바닥: StaticBody3D, BoxMesh 30×1×30, 회색(0.5, 0.5, 0.5)
> - 장애물 박스 8개: StaticBody3D, BoxMesh 2×2×2, 갈색
>   위치: (±5, 1, ±5), (±10, 1, ±5), (±5, 1, ±10), (±10, 1, ±10) 근방에 약간씩 랜덤
> - DirectionalLight3D: rotation (-45, 45, 0), 그림자 활성화
> - WorldEnvironment: 하늘색 배경, 약한 안개
> - NavigationRegion3D: 바닥 전체를 커버 (장애물 주변 자동 회피)
>
> NavigationMesh Bake는 에디터에서 직접 해야 하니 안내 메시지 표시해줘"

### Step 3: 플레이어

Claude에게 요청:
> "3인칭 플레이어 씬을 만들어줘.
> `res://scenes/player.tscn`, `res://scripts/player.gd`
>
> 씬 구조:
> Player (CharacterBody3D)
> ├── MeshInstance3D (CapsuleMesh, 파란색)
> ├── CollisionShape3D (CapsuleShape3D)
> └── CameraPivot (Node3D)
>     └── SpringArm3D (length 5)
>         └── Camera3D
>
> 기능:
> - WASD 이동 (카메라 기준 방향)
> - 마우스 우클릭 드래그로 카메라 회전 (sensitivity 0.003)
> - Space 점프 (jump_force 8, gravity 20)
> - 달리기 없음 (speed 6 고정)
> - _ready()에서 SpringArm3D.add_excluded_object(get_rid()) 적용
> - take_damage(amount: int): GameManager.take_damage() 호출 + 0.5초 무적 + 빨간 깜빡임
> - 'player' 그룹 추가"

### Step 4: 코인 아이템

Claude에게 요청:
> "코인 아이템 씬을 만들어줘.
> `res://scenes/items/coin.tscn`, `res://scripts/coin.gd`
>
> 씬 구조:
> Coin (Node3D)
> ├── MeshInstance3D (CylinderMesh radius 0.3, height 0.1, 금색)
> ├── CollisionShape3D (CylinderShape3D)
> ├── Area3D
> │   └── CollisionShape3D (같은 크기)
> └── AnimationPlayer
>
> 기능:
> - AnimationPlayer: Y축 무한 회전 (2초/바퀴) + position.y ±0.2 부유 (사인, 1.5초/사이클)
> - Area3D body_entered: 'player' 그룹 확인 후 수집 처리
> - 수집: Tween으로 위로 떠오르며 투명해짐 (0.4초) → queue_free()
> - GameManager.add_score(10), GameManager.collect_coin() 호출
> - 'coin' 그룹 추가"

### Step 5: 적 AI

Claude에게 요청:
> "플레이어를 추격하는 적 씬을 만들어줘.
> `res://scenes/enemy.tscn`, `res://scripts/enemy.gd`
>
> 씬 구조:
> Enemy (CharacterBody3D)
> ├── MeshInstance3D (CapsuleMesh, 빨간색)
> ├── CollisionShape3D (CapsuleShape3D)
> ├── NavigationAgent3D
> ├── DetectionArea (Area3D, 반지름 12 구형)
> │   └── CollisionShape3D
> └── AttackArea (Area3D, 반지름 1.5 구형)
>     └── CollisionShape3D
>
> 상태 머신: IDLE → CHASE → ATTACK
> - IDLE: 제자리 대기, DetectionArea에 플레이어 진입 시 CHASE
> - CHASE: NavigationAgent3D로 플레이어 추격 (speed 4)
> - ATTACK: 플레이어와 1.5m 이내 시 공격 (1초 쿨다운, damage 15)
> - 사망 처리 없음 (이 미니 프로젝트에서는 적이 죽지 않음)
> - 'enemy' 그룹 추가"

### Step 6: HUD

Claude에게 요청:
> "게임 HUD를 만들어줘.
> `res://scenes/ui/hud.tscn`, `res://scripts/hud.gd`
>
> - CanvasLayer 기반
> - 왼쪽 위: 체력바 ProgressBar (너비 200, 빨간색)
> - 오른쪽 위: 코인 카운터 Label ('코인: 3/10' 형식, 흰색)
> - 화면 중앙: 작은 크로스헤어 (흰색 십자가, 10x10px)
>
> GameManager Signal 연결:
> - health_changed → 체력바 업데이트 + 30 이하면 빨갛게 깜빡
> - coin_collected → 코인 카운터 업데이트 + 스케일 팝업"

### Step 7: UI 씬들

Claude에게 요청:
> "미니 게임의 UI 씬 4개를 만들어줘.
>
> 1. `res://scenes/ui/main_menu.tscn`
>    - 게임 제목 Label (큰 텍스트, 화면 위쪽 중앙)
>    - 'Start Game' 버튼 → level1.tscn 페이드 전환
>
> 2. `res://scenes/ui/game_over.tscn`
>    - 'GAME OVER' 텍스트 (빨간색, 큰 폰트)
>    - 최종 점수 표시 (GameManager.score 읽기)
>    - 'Retry' 버튼: GameManager.reset() 후 level1.tscn 페이드 전환
>    - 'Main Menu' 버튼: main_menu.tscn 전환
>
> 3. `res://scenes/ui/clear.tscn`
>    - 'STAGE CLEAR!' 텍스트 (금색, 큰 폰트)
>    - 최종 점수 표시
>    - 'Play Again' 버튼: GameManager.reset() 후 level1 재시작
>    - 'Main Menu' 버튼
>
> 4. `res://scenes/ui/pause_menu.tscn`
>    - 반투명 검은 배경
>    - 'Resume', 'Restart', 'Main Menu' 버튼
>    - Process Mode: Always
>
> 씬 전환에는 0.4초 페이드 인/아웃 (ColorRect + Tween)
> GameManager Signal 연결: game_over → game_over 씬, level_clear → clear 씬"

### Step 8: 레벨에 모든 요소 배치

Claude에게 요청:
> "level1.tscn에 모든 요소를 배치해줘.
>
> - 플레이어 인스턴스: 중앙 (0, 1, 0)
> - 적 인스턴스 3마리: (10, 1, 10), (-10, 1, 10), (0, 1, -12)
> - 코인 인스턴스 10개: 맵 전체에 분산 배치 (y=0.5, 장애물과 겹치지 않게)
> - HUD 씬: CanvasLayer로 포함
> - Spawner 없음 (고정 배치)
>
> _ready()에서:
> - GameManager.reset() 호출
> - GameManager.set_coin_total(10) 호출
> - GameManager Signal → game_over/level_clear 씬 전환 연결
>
> project.godot:
> - 메인 씬을 main_menu.tscn으로 설정"

---

## 개발 중 자주 만나는 문제

### NavigationMesh Bake 안 하면 적이 안 움직임
```
Godot 에디터에서:
1. level1.tscn 열기
2. NavigationRegion3D 노드 선택
3. Inspector 상단 "Bake NavigationMesh" 버튼 클릭
4. Ctrl+S 저장
```

### 씬이 로드되자마자 GameManager.health가 0
`level1.tscn`의 `_ready()`에서 `GameManager.reset()`을 먼저 호출했는지 확인.
씬 전환 순서가 중요하다.

### 코인 Area3D가 플레이어를 감지 못 함
- 플레이어가 'player' 그룹에 추가되어 있는지 확인
- coin.gd의 body_entered에서 `body.is_in_group("player")` 조건 확인
- Collision Layer/Mask 설정 확인 (에디터 Inspector)

### SpringArm3D가 카메라를 당김 (착지 버그)
- player.gd의 `_ready()`에 `$CameraPivot/SpringArm3D.add_excluded_object(get_rid())` 있는지 확인

### 적이 플레이어를 통과함
- enemy.gd에서 `move_and_slide()` 호출 확인
- 적의 CollisionLayer와 플레이어의 CollisionMask가 서로 겹치는지 확인

---

## 완성 후 확인
- [ ] 메인 메뉴에서 Start 누르면 페이드와 함께 게임 시작
- [ ] WASD로 이동, 마우스 우클릭 드래그로 카메라 회전
- [ ] 코인에 닿으면 수집 애니메이션 + HUD 카운터 증가
- [ ] 적에게 닿으면 체력 감소 + 피격 효과
- [ ] 체력 0 → 게임오버 씬 (최종 점수 표시)
- [ ] 코인 10개 수집 → 클리어 씬 (최종 점수 표시)
- [ ] ESC로 일시정지 메뉴 열림
- [ ] 페이드 전환이 모든 씬 이동에서 작동

---

## 이 다음은?

미니 프로젝트를 완성했다면, **[Ch18 — 게임 아키텍처 & 리팩토링](./ch18_architecture_refactoring.md)**에서 코드 품질을 한 단계 높이는 설계 패턴을 배우거나, 배운 개념들을 바탕으로 **자신만의 게임 아이디어**를 Claude와 함께 설계해보자.

**좋은 시작 질문:**
> "나는 [장르] 게임을 만들고 싶어.
> 핵심 메카닉은 [아이디어]야.
> 어떤 씬 구조와 시스템이 필요할지 설계해줘.
> 단계별 제작 순서도 알려줘."

**확장 아이디어:**
- 무기 시스템 추가 (총/근접 공격)
- 아이템 드롭 (체력 회복 포션)
- 스폰 시스템으로 무한 적 생성
- 타이머 추가 (제한 시간 내 클리어)
- 다음 레벨 (level2.tscn) 추가
- 세이브 시스템 (현재는 매번 처음부터)
- BGM/효과음 추가
- Web 빌드로 itch.io에 배포

**포트폴리오로 공유할 때:**
- itch.io Web 빌드 링크
- 스크린샷 3~5장
- 짧은 게임플레이 영상 (30초)
- 사용 기술 정리 (Godot 4, GDScript, NavigationAgent3D, etc.)
