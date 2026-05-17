# Ch08 정답 — 3D 애셋 가져오기

**Q1.** ③ `.glb`

---

**Q2.** `.glb`는 메시, 텍스처, 애니메이션, 재질 정보가 **파일 하나에** 모두 포함되어 있다. `.obj`는 `.obj`, `.mtl`, 텍스처 이미지 파일들을 따로 관리해야 하고, 하나라도 경로가 틀리면 텍스처가 사라진다.

---

**Q3.** `.import` 파일이 생성된다. Godot는 원본 `.glb`를 Godot 렌더러에 최적화된 내부 형식으로 변환해 `.godot/imported/`에 저장하고, `.import` 파일이 "원본 → 사본" 매핑을 기록한다. 이 파일을 지우거나 수동 편집하면 임포트 매핑이 깨진다.

---

**Q4.**
- `Albedo Color`: 기본 색상 (빛이 없을 때의 순수한 색)
- `Metallic`: 0~1. 0이면 비금속, 1이면 금속처럼 주변을 반사
- `Roughness`: 0~1. 0이면 거울처럼 매끄럽고, 1이면 분필처럼 거칠음

---

**Q5.**
- Metallic 0, Roughness 1 → ② 돌/시멘트
- Metallic 1, Roughness 0 → ① 거울같은 금속(크롬)
- Metallic 0, Roughness 0 → ③ 유리/매끄러운 플라스틱

---

**Q6.**
```gdscript
func spawn_tree(pos: Vector3) -> void:
    var model_scene = load("res://assets/models/tree.glb")
    var tree = model_scene.instantiate()
    tree.position = pos
    add_child(tree)
```

---

**Q7.** `.tscn`으로 변환하면 물리 충돌, 스크립트, Area3D 등을 `.tscn` 안에 영구적으로 저장할 수 있다. 여러 씬에서 재사용할 때 한 곳(`.tscn`)만 수정하면 전체에 반영된다.

---

**Q8.** X

LOD는 **멀리 있는** 오브젝트일수록 낮은 해상도 메시를 사용한다. 멀리서는 삼각형 수가 적어도 품질 차이를 거의 못 느끼기 때문에 성능을 아낄 수 있다.
