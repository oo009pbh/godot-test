# Ch08 퀴즈 — 3D 애셋 가져오기

---

## 문제

**Q1.** Godot에서 3D 파일을 가져올 때 권장하는 형식은?

① `.obj`  ② `.fbx`  ③ `.glb`  ④ `.blend`

---

**Q2.** `.glb`가 `.obj`보다 나은 이유를 설명하라.

---

**Q3.** Godot가 `.glb` 파일을 임포트할 때 자동으로 생성하는 파일은 무엇이고, 이것을 직접 수정하거나 삭제하면 안 되는 이유는?

---

**Q4.** `StandardMaterial3D`에서 다음 속성의 역할을 설명하라.

- `Albedo Color`: ?
- `Metallic`: ?
- `Roughness`: ?

---

**Q5.** 다음 Metallic/Roughness 조합이 어떻게 보이는지 연결하라.

| Metallic | Roughness | 결과 |
|----------|-----------|------|
| 0 | 1 | ? |
| 1 | 0 | ? |
| 0 | 0 | ? |

① 거울같은 금속(크롬)  ② 돌/시멘트  ③ 유리/매끄러운 플라스틱

---

**Q6.** 코드에서 `.glb` 모델을 동적으로 불러와 씬에 추가하는 올바른 코드를 완성하라.

```gdscript
func spawn_tree(pos: Vector3) -> void:
    var model_scene = ________("res://assets/models/tree.glb")
    var tree = model_scene.________()
    tree.position = pos
    ________(tree)
```

---

**Q7.** `.glb`를 씬으로 변환(`.tscn`)한 뒤 사용하면 좋은 이유는?

---

**Q8.** (O/X) LOD(Level of Detail)는 카메라에서 가까운 오브젝트일수록 더 낮은 해상도 메시를 사용한다.

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.** ③ `.glb`

**Q2.** `.glb`는 메시, 텍스처, 애니메이션, 재질 정보가 **파일 하나에** 모두 포함되어 있다. `.obj`는 `.obj`, `.mtl`, 텍스처 이미지 파일들을 따로 관리해야 하고, 하나라도 경로가 틀리면 텍스처가 사라진다.

**Q3.** `.import` 파일이 생성된다. Godot는 원본 `.glb`를 Godot 렌더러에 최적화된 내부 형식으로 변환해 `.godot/imported/`에 저장하고, `.import` 파일이 "원본 → 사본" 매핑을 기록한다. 이 파일을 지우거나 수동 편집하면 임포트 매핑이 깨진다.

**Q4.**
- `Albedo Color`: 기본 색상 (빛이 없을 때의 순수한 색)
- `Metallic`: 0~1. 0이면 비금속, 1이면 금속처럼 주변을 반사
- `Roughness`: 0~1. 0이면 거울처럼 매끄럽고, 1이면 분필처럼 거칠음

**Q5.**
- Metallic 0, Roughness 1 → ② 돌/시멘트
- Metallic 1, Roughness 0 → ① 거울같은 금속(크롬)
- Metallic 0, Roughness 0 → ③ 유리/매끄러운 플라스틱

**Q6.**
```gdscript
func spawn_tree(pos: Vector3) -> void:
    var model_scene = load("res://assets/models/tree.glb")
    var tree = model_scene.instantiate()
    tree.position = pos
    add_child(tree)
```

**Q7.** `.tscn`으로 변환하면 물리 충돌, 스크립트, Area3D 등을 `.tscn` 안에 영구적으로 저장할 수 있다. 여러 씬에서 재사용할 때 한 곳(`.tscn`)만 수정하면 전체에 반영된다.

**Q8.** X — LOD는 **멀리 있는** 오브젝트일수록 낮은 해상도 메시를 사용한다. 멀리서는 삼각형 수가 적어도 품질 차이를 거의 느끼지 못하기 때문에 성능을 아낄 수 있다.

</details>
