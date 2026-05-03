# Ch08 — 3D 애셋 가져오기

---

## 개념

### Godot에서 지원하는 3D 파일 형식

| 형식 | 특징 | 권장도 |
|------|------|--------|
| `.glb` | GLTF 바이너리. 텍스처 포함. 범용 | ★★★ 권장 |
| `.gltf` | GLTF 텍스트. 텍스처 별도 | ★★ |
| `.fbx` | 언리얼/마야 표준. Godot 지원 제한적 | ★ |
| `.obj` | 단순한 메시만. 텍스처 별도 | ★ |

→ **항상 `.glb`를 사용하자.**

### 무료 3D 애셋 소스

| 사이트 | 특징 |
|--------|------|
| [Kenney.nl](https://kenney.nl/assets) | 게임 개발용 무료 팩. 품질 높음 |
| [Sketchfab (Free)](https://sketchfab.com/features/free-3d-models) | 다양한 모델. 라이선스 확인 필요 |
| [Quaternius](https://quaternius.com) | Godot 친화적인 무료 팩 |

### .glb 임포트 과정

```
1. .glb 파일을 res://assets/models/ 에 복사 (Finder에서 드래그)
2. Godot 에디터 FileSystem 패널에서 자동으로 감지됨
3. 파일을 더블클릭 → 임포트 설정 확인
4. 씬으로 드래그하거나 코드에서 load() 사용
```

**임포트 설정 (Inspector > Import 탭):**
- `Meshes > Generate LODs`: 성능 최적화용 LOD 생성 여부
- `Animation > Import`: 애니메이션 포함 여부
- `Skins`: 스킨 메시(캐릭터) 여부

### MeshInstance3D에 애셋 적용

**방법 1: 에디터에서 드래그**
- FileSystem에서 .glb 파일을 뷰포트로 드래그

**방법 2: 코드에서 로드**
```gdscript
var model = load("res://assets/models/character.glb")
var instance = model.instantiate()
add_child(instance)
```

### Material (재질)
메시의 색상, 질감, 반사를 결정.

**StandardMaterial3D 주요 속성:**
| 속성 | 역할 |
|------|------|
| `Albedo > Color` | 기본 색상 |
| `Albedo > Texture` | 텍스처 이미지 |
| `Metallic` | 금속 느낌 (0~1) |
| `Roughness` | 거칠기. 낮을수록 반짝임 (0~1) |
| `Emission` | 자체 발광 색상 |

**코드에서 Material 생성:**
```gdscript
var mat = StandardMaterial3D.new()
mat.albedo_color = Color.RED
$MeshInstance3D.material_override = mat
```

---

## 실습

### 실습 8-1: Kenney 애셋 가져오기
1. [kenney.nl/assets/nature-kit](https://kenney.nl/assets/nature-kit) 에서 무료 팩 다운로드
2. `.glb` 파일을 `res://assets/models/` 에 복사
3. Claude에게 다음 요청:

> "방금 `res://assets/models/` 에 Kenney 애셋 .glb 파일을 넣었어.
> 파일 목록: [파일 이름들]
> 이 모델들을 씬에 배치하는 스크립트를 만들어줘.
> 바닥 위에 격자 형태로 10개씩 배치해줘."

### 실습 8-2: 코드로 Material 변경
Claude에게 다음 요청:

> "현재 씬의 MeshInstance3D들에 코드로 Material을 적용해줘.
> 빨간색, 초록색, 파란색 Material을 무작위로 적용하는 스크립트를 만들어줘.
> `res://scripts/color_randomizer.gd`로 만들어줘."

---

## 확인 포인트
- [ ] 왜 `.glb`를 쓰는지 안다
- [ ] 에디터에서 파일을 드래그해서 씬에 넣을 수 있다
- [ ] `StandardMaterial3D`의 Albedo, Metallic, Roughness가 무엇인지 안다

## 다음 챕터
[Ch09 — 플레이어 컨트롤러](./ch09_player_controller.md)
