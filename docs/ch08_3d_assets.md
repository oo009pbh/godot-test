# Ch08 — 3D 애셋 가져오기

---

## 개념

### 3D 애셋이란?

게임에서 보이는 모든 오브젝트(나무, 건물, 캐릭터, 소품)는 누군가 만든 **3D 모델 파일**이다.
이 파일을 Godot로 가져와 씬에 배치하는 것을 **임포트(Import)** 라고 한다.

3D 모델 파일에는 세 가지 정보가 들어있다:

```
3D 모델 파일
├── Mesh (메시)      ← 오브젝트의 형태. 수천 개의 삼각형으로 구성됨
├── Material (재질)  ← 표면의 색상, 질감, 반사 정보
└── Animation (애니메이션) ← 캐릭터의 걷기/뛰기 동작 (있을 경우)
```

이 세 가지를 한 파일에 담아서 Godot로 가져온다.

---

### Godot에서 지원하는 3D 파일 형식

| 형식 | 특징 | 권장도 |
|------|------|--------|
| `.glb` | GLTF 바이너리. 텍스처·애니메이션 모두 포함. 범용 표준 | ★★★ 권장 |
| `.gltf` | GLTF 텍스트 버전. 텍스처는 별도 파일. 수정하기 쉬움 | ★★ |
| `.fbx` | 언리얼·마야의 전통 표준. Godot 지원이 제한적 | ★ |
| `.obj` | 아주 오래된 형식. 메시 데이터만 있고 애니메이션 없음 | ★ |

**왜 항상 `.glb`를 써야 하는가?**

`.glb`는 **모든 것이 파일 하나에** 들어있다.
텍스처 이미지, 애니메이션, 재질 정보가 전부 바이너리 하나로 압축되어 있어서
파일을 하나만 복사하면 된다.

반면 `.obj`는 `.obj` + `.mtl`(재질) + 텍스처 이미지 파일들을 따로 관리해야 한다.
파일 하나라도 경로가 틀리면 텍스처가 통째로 사라진다.

`.glb` = USB 드라이브 하나에 모든 자료가 들어있는 것.
`.obj` = 여러 폴더에 자료가 흩어져 있고, 경로 목록이 담긴 메모가 따로 필요한 것.

**항상 `.glb`를 사용하자.**

---

### 무료 3D 애셋 소스

| 사이트 | 특징 |
|--------|------|
| [Kenney.nl](https://kenney.nl/assets) | 게임 개발용 무료 팩. 품질 높고 라이선스 걱정 없음 |
| [Sketchfab (Free)](https://sketchfab.com/features/free-3d-models) | 다양한 모델. 다운로드 전 라이선스 반드시 확인 |
| [Quaternius](https://quaternius.com) | Godot 친화적인 캐릭터·소품 무료 팩 |
| [Poly Pizza](https://poly.pizza) | 로우폴리 모델. Kenney와 비슷한 스타일 |

**라이선스 주의:**
`CC0` = 완전 무료, 상업 이용 가능.
`CC-BY` = 무료이지만 출처를 표시해야 함.
`CC-BY-NC` = 비상업적 용도만 허용.
무료라고 무조건 상업 게임에 쓸 수 있는 건 아니다.

---

### .glb 임포트 과정

```
1단계: 파일 복사
  Finder에서 .glb 파일을 res://assets/models/ 폴더로 드래그

2단계: Godot 자동 감지
  Godot 에디터 FileSystem 패널에 파일이 자동으로 나타남
  내부적으로 .import 파일을 생성해 최적화된 내부 형식으로 변환

3단계: 씬에 배치
  방법 A: FileSystem에서 씬 뷰포트로 드래그 (가장 간단)
  방법 B: FileSystem에서 노드의 Mesh 슬롯으로 드래그
  방법 C: 코드에서 load()로 불러오기
```

**Godot가 .import 파일을 만드는 이유:**
원본 `.glb` 파일을 그대로 쓰면 Godot 렌더러와 완전히 호환이 안 될 수 있다.
그래서 Godot는 임포트할 때 **자체 최적화 형식으로 변환한 사본**을 `.godot/imported/` 안에 숨겨두고, `.import` 파일에 "원본 → 사본" 매핑을 기록한다.

실제로 게임이 실행될 때 Godot는 `.glb`가 아닌 최적화된 사본을 쓴다.
따라서 `.import` 파일은 지우거나 수동으로 편집하면 안 된다.

---

### 임포트 설정

FileSystem에서 `.glb` 파일을 클릭하면 하단에 **Import** 탭이 나타난다.

**주요 설정:**

| 설정 | 역할 | 언제 바꾸나 |
|------|------|------------|
| `Meshes > Generate LODs` | 거리에 따라 저해상도 메시 자동 생성 | 씬에 오브젝트가 많을 때 |
| `Animation > Import` | 애니메이션 데이터 포함 여부 | 애니메이션 없는 소품은 꺼서 용량 절약 |
| `Skins` | 뼈대(Skeleton)와 연결된 캐릭터 메시 | 캐릭터 모델일 때 |
| `Meshes > Lightmap UV` | 정적 조명 UV 생성 | 베이크드 라이팅 쓸 때 |

**LOD란?**
Level of Detail의 약자.
카메라에서 멀리 있는 오브젝트는 삼각형 수를 줄인 저해상도 버전으로 교체해서 성능을 아낀다.
10m 거리의 나무와 1000m 거리의 나무를 같은 해상도로 그리는 건 낭비다.

---

### 씬 배치 방법 비교

**방법 1: 에디터에서 드래그**

FileSystem 패널에서 `.glb` 파일을 뷰포트로 드래그하면
Godot가 자동으로 Node3D를 만들고 그 안에 모델 구조를 넣어준다.

```
드래그 결과로 생성되는 씬 구조 예시:
character (Node3D)        ← .glb 파일 이름이 루트 노드 이름
└── Armature (Skeleton3D) ← 뼈대 (캐릭터의 경우)
    └── body (MeshInstance3D) ← 실제 메시
```

**방법 2: 코드에서 동적 로드**

```gdscript
# 게임 실행 중 필요할 때 불러오기
var model_scene = load("res://assets/models/tree.glb")
var tree = model_scene.instantiate()
tree.position = Vector3(5, 0, 3)
add_child(tree)
```

드래그로 배치하는 것과 결과는 같지만, 코드로 위치와 수량을 제어할 수 있다.
여러 개를 자동으로 배치하거나, 특정 조건에서 오브젝트를 생성할 때 유용하다.

**방법 3: PackedScene으로 재사용**

```gdscript
# .glb는 PackedScene처럼 다룰 수 있다
@export var tree_model: PackedScene  # Inspector에서 .glb 파일 할당

func spawn_tree(pos: Vector3):
    var tree = tree_model.instantiate()
    tree.position = pos
    add_child(tree)
```

`@export`를 쓰면 Inspector에서 드래그로 `.glb` 파일을 할당할 수 있다.
코드에 경로를 하드코딩하지 않아도 돼서 유연하다.

---

### Material (재질) — 표면이 어떻게 보이는가

같은 형태(Mesh)라도 재질에 따라 전혀 다르게 보인다.
나무 구를 만들면 도자기처럼 보일 수도 있고, 유리처럼 보일 수도 있다.

**현실 비유:**
Mesh = 찰흙으로 만든 모양.
Material = 그 위에 바르는 페인트 + 니스 + 도금.
같은 찰흙 모양도 페인트에 따라 플라스틱이 되거나 금속이 된다.

---

### StandardMaterial3D — Godot의 기본 재질

Godot에서 가장 많이 쓰는 재질 타입. **PBR(물리 기반 렌더링)** 방식이다.

```
StandardMaterial3D 주요 속성:

Albedo (알베도)
  ├── Color   : 기본 색상. 빛이 없을 때의 순수한 색
  └── Texture : 색상 대신 이미지 파일로 표면 색상 지정

Metallic (금속도)
  └── 값: 0~1. 0이면 비금속(플라스틱), 1이면 금속
      금속일수록 주변 환경을 반사함

Roughness (거칠기)
  └── 값: 0~1. 0이면 거울처럼 매끄럽고, 1이면 분필처럼 거칠음

Emission (발광)
  └── 자체적으로 빛을 내는 색. 형광등, LED, 마법 효과에 사용
      실제 빛은 내지 않음 — 그냥 밝아 보이는 것

Normal Map (법선 맵)
  └── 표면에 요철이 있는 것처럼 착각하게 만드는 이미지
      실제로 폴리곤을 더 추가하지 않고 디테일을 살림
```

**Metallic + Roughness 조합 예시:**

| Metallic | Roughness | 보이는 결과 |
|----------|-----------|------------|
| 0 | 1 | 돌, 시멘트, 분필 |
| 0 | 0 | 유리, 매끄러운 플라스틱 |
| 1 | 0 | 거울 같은 금속, 크롬 |
| 1 | 1 | 긁힌 철, 녹슨 금속 |

---

### 코드에서 Material 적용

```gdscript
# 새 Material 만들기
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(1, 0, 0)  # 빨간색 (R, G, B)
mat.roughness = 0.3                 # 약간 반짝임
mat.metallic = 0.8                  # 금속 느낌

# MeshInstance3D에 적용
$MeshInstance3D.material_override = mat
```

**`material_override` vs `surface_material_override`:**

`material_override` = 메시 전체에 하나의 재질 덮어씌우기. 간단하지만 모든 서피스에 같은 재질이 들어간다.

`surface_material_override[0]` = 특정 서피스(면)만 바꾸기. 캐릭터 상의/하의를 따로 바꿀 때 사용.

---

### 텍스처 (Texture) — 이미지로 표면 색상 입히기

Albedo Color만 쓰면 단색이라 단조롭다.
텍스처는 **이미지 파일을 표면에 붙이는 것**이다.

```gdscript
var mat = StandardMaterial3D.new()
# 이미지 파일을 텍스처로 불러와 적용
mat.albedo_texture = load("res://assets/textures/wood_planks.png")
$MeshInstance3D.material_override = mat
```

**UV란?**
텍스처가 메시 표면에 어떻게 펼쳐지는지 정의하는 2D 좌표계.
UV가 없으면 이미지가 어디서 시작해 어디서 끝날지 Godot가 알 수 없다.
대부분의 `.glb` 모델은 UV가 이미 포함되어 있어서 별도로 만들 필요 없다.

---

### 씬 인스턴스 vs 직접 배치

`.glb`를 씬으로 미리 변환해 두면 재사용이 편리하다.

```
[직접 배치]
world.tscn
└── tree.glb (직접 드래그)  ← world.tscn에서만 사용 가능

[씬으로 변환 후 배치]
1. tree.glb를 열어 tree.tscn으로 저장
2. tree.tscn에서 충돌 모양, 스크립트 등 추가 설정
3. world.tscn에 tree.tscn 인스턴스 배치

tree.tscn
├── MeshInstance3D (나무 모델)
├── CollisionShape3D (충돌 범위)  ← 물리 처리 추가
└── Area3D (상호작용 범위)         ← 플레이어가 가까이 오면 감지
```

`.glb`를 `.tscn`으로 변환해 두면:
- 물리, 스크립트 등을 `.tscn` 안에 저장할 수 있다
- 여러 씬에서 재사용할 때 한 곳만 수정하면 전체에 반영된다

---

## 실습

### 실습 8-1: Kenney 애셋 가져오기

1. [kenney.nl/assets/nature-kit](https://kenney.nl/assets/nature-kit) 에서 무료 팩 다운로드
2. `.glb` 파일을 `res://assets/models/` 폴더에 복사
3. Claude에게 다음 요청:

> "방금 `res://assets/models/` 에 Kenney Nature Kit에서 가져온 .glb 파일을 넣었어.
> 파일 목록: [파일 이름들]
> 이 모델들을 씬에 배치하는 스크립트를 만들어줘.
> 바닥 위에 격자 형태로 배치하고, 각 모델마다 충돌 모양도 추가해줘.
> `res://scripts/asset_placer.gd`로 만들어줘."

### 실습 8-2: 코드로 Material 변경

Claude에게 다음 요청:

> "현재 씬의 플레이어 캡슐 MeshInstance3D에 코드로 StandardMaterial3D를 적용해줘.
> 빨간색, 초록색, 파란색 Material 중 하나를 스페이스바를 누를 때마다 무작위로 바꿔줘.
> `scripts/player.gd`에 추가해줘."

### 실습 8-3: 텍스처 적용

Claude에게 다음 요청:

> "바닥(Ground) MeshInstance3D에 타일 텍스처를 적용해줘.
> `res://assets/textures/` 폴더에 있는 이미지를 사용하고,
> 텍스처가 바닥 전체에 걸쳐 반복(tiling)되게 설정해줘.
> UV 스케일은 바닥 크기에 맞게 조정해줘."

---

## 확인 포인트

- [ ] 왜 `.glb`가 `.obj`나 `.fbx`보다 나은지 설명할 수 있다
- [ ] Godot가 `.import` 파일을 만드는 이유를 안다
- [ ] `StandardMaterial3D`의 Albedo, Metallic, Roughness가 무엇인지 안다
- [ ] Metallic 1 + Roughness 0이 크롬처럼 보이는 이유를 안다
- [ ] 코드에서 `load()`로 모델을 불러와 씬에 추가할 수 있다
- [ ] `.glb`를 `.tscn`으로 변환하는 게 언제 유리한지 안다

## 다음 챕터

[Ch09 — 플레이어 컨트롤러](./ch09_player_controller.md)
