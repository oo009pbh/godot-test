# Ch17 — 미니 프로젝트: 3인칭 어드벤처 (종합)

> Phase 1~4의 모든 개념을 통합한 완성형 미니 게임을 만든다.
> 모든 파일은 Claude가 직접 생성/수정한다.

---

## 게임 기획

**장르:** 3인칭 어드벤처  
**목표:** 맵에 흩어진 코인을 모두 모으면 클리어  
**플레이 타임:** 약 2~3분

### 기능 목록
- [ ] WASD 이동 + 마우스 카메라
- [ ] 점프
- [ ] 적 (플레이어를 추격, 닿으면 데미지)
- [ ] 코인 수집 (Area3D, 애니메이션)
- [ ] 체력 시스템 (HUD 표시)
- [ ] 스코어 (HUD 표시)
- [ ] 모든 코인 수집 시 클리어 씬 전환
- [ ] 체력 0 시 게임오버 씬 전환
- [ ] 세이브 없음 (미니 게임이므로 생략)

### 씬 구조
```
res://scenes/
├── ui/
│   ├── main_menu.tscn
│   ├── hud.tscn
│   ├── game_over.tscn
│   └── clear.tscn
├── player.tscn
├── enemy.tscn
├── coin.tscn
└── level1.tscn         ← 메인 게임 씬
```

---

## 단계별 제작 순서

### Step 1: 레벨 기반 씬

Claude에게 요청:
> "Godot 4 3인칭 어드벤처 게임의 레벨 씬을 만들어줘.
> `res://scenes/level1.tscn`
> - 바닥 (StaticBody3D, 30x1x30, 회색)
> - 장애물 박스 10개 (StaticBody3D, 무작위 배치)
> - DirectionalLight3D (낮 분위기)
> - WorldEnvironment (하늘색 배경)
> - NavigationRegion3D 포함 (장애물 주변 자동 회피)"

### Step 2: 플레이어

Claude에게 요청:
> "3인칭 플레이어 씬을 만들어줘.
> `res://scenes/player.tscn`, `res://scripts/player.gd`
> - WASD + 마우스 카메라 + Space 점프
> - 이동속도 6, 달리기(Shift) 12, 점프력 5
> - health 변수 (최대 100), take_damage(amount) 함수
> - 데미지 받으면 0.5초 무적 (무적 중 반투명)
> - health 0이면 GameManager.game_over Signal 발생
> - 'player' 그룹에 추가"

### Step 3: 코인 아이템

Claude에게 요청:
> "코인 아이템 씬을 만들어줘.
> `res://scenes/coin.tscn`
> - CylinderMesh (납작한 원기둥, 금색 Material)
> - AnimationPlayer: Y축 회전 + 위아래 부유
> - Area3D: 플레이어 접촉 시 GameManager.add_score(10) 호출 후 queue_free()
> - 수집 시 간단한 파티클 효과"

### Step 4: 적 AI

Claude에게 요청:
> "플레이어를 추격하는 적 씬을 만들어줘.
> `res://scenes/enemy.tscn`, `res://scripts/enemy.gd`
> - 빨간 캡슐 모양
> - NavigationAgent3D로 플레이어 추격
> - 감지 범위 12m, 공격 범위 1.5m
> - 닿으면 player.take_damage(10) 호출 (1초 쿨다운)
> - 'enemy' 그룹에 추가"

### Step 5: HUD + GameManager

Claude에게 요청:
> "GameManager Autoload와 HUD를 만들어줘.
> GameManager: `res://scripts/game_manager.gd`
> - score, coin_count(현재), coin_total(전체) 관리
> - Signal: score_changed, health_changed, game_over, level_clear
> - 코인을 모두 모으면 level_clear Signal 발생
>
> HUD: `res://scenes/ui/hud.tscn`
> - 왼쪽 위: 체력바
> - 오른쪽 위: 코인 카운터 (3/10 형식)
> - GameManager Signal로 자동 업데이트"

### Step 6: 메뉴 씬들

Claude에게 요청:
> "메인 메뉴, 게임오버, 클리어 씬을 만들어줘.
> - `res://scenes/ui/main_menu.tscn`: 타이틀 + Start 버튼
> - `res://scenes/ui/game_over.tscn`: 'Game Over' + Retry 버튼 + 최종 점수
> - `res://scenes/ui/clear.tscn`: 'Stage Clear!' + 점수 + Next(메인으로) 버튼
> - 씬 전환에 페이드 인/아웃 효과 추가"

### Step 7: 레벨에 모든 요소 배치

Claude에게 요청:
> "level1.tscn에 플레이어, 적 3마리, 코인 10개를 배치해줘.
> - 플레이어: 중앙 (0, 1, 0)
> - 코인: 맵 전체에 분산 배치
> - 적: 맵 가장자리에서 시작
> - HUD 씬을 CanvasLayer로 포함
> - project.godot 메인 씬을 main_menu로 설정"

---

## 완성 후 확인
- [ ] 메인 메뉴에서 Start 누르면 게임 시작
- [ ] WASD로 이동, 마우스로 카메라
- [ ] 코인 수집 시 HUD 카운터 증가
- [ ] 적에게 닿으면 체력 감소
- [ ] 체력 0 → 게임오버 씬
- [ ] 코인 모두 수집 → 클리어 씬

---

## 이 다음은?
미니 프로젝트를 완성했다면, 배운 개념들을 바탕으로 **자신만의 게임 아이디어**를 Claude와 함께 설계해보자.

좋은 시작 질문:
> "나는 [장르] 게임을 만들고 싶어. 핵심 메카닉은 [아이디어]야.
> 어떤 씬 구조와 시스템이 필요할지 설계해줘."
