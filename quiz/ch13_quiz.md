# Ch13 퀴즈 — 파티클 & VFX

---

## 문제

**Q1.** `GPUParticles3D`에서 `one_shot = true`와 `one_shot = false`의 차이를 설명하라.

---

**Q2.** 폭발 효과를 만들 때 `explosiveness`를 `1.0`으로 설정하는 이유는?

---

**Q3.** 다음 중 **AnimationPlayer**가 적합한 상황은?

① 런타임에 동적으로 생성되는 간단한 이동/페이드  
② 매개변수가 자주 바뀌는 파티클 색상 변경  
③ 에디터에서 여러 속성을 동시에 미리 확인하며 만드는 복잡한 캐릭터 걷기 애니메이션  
④ 씬 전환 페이드 효과

---

**Q4.** 다음 Tween 코드에서 이징 함수 `EASE_OUT`이 가장 자연스럽게 느껴지는 이유는?

```gdscript
tween.set_ease(Tween.EASE_OUT)
```

---

**Q5.** 아래 아이템 수집 효과 코드를 분석하라. `CollisionShape3D.disabled = true`를 먼저 하는 이유는?

```gdscript
func collect() -> void:
    $CollisionShape3D.disabled = true
    var tween = create_tween()
    tween.tween_property(self, "position:y", position.y + 1.5, 0.5)
    tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
    await tween.finished
    queue_free()
```

---

**Q6.** `GPUParticles3D`와 `CPUParticles3D` 중 Web 빌드나 저사양 기기에서 사용해야 하는 것은?

---

**Q7.** `await tween.finished` 이후에 `queue_free()`를 호출하는 이유는?

---

**Q8.** 다음 이징 함수의 느낌을 설명하라.

- `EASE_IN`: ?
- `EASE_OUT`: ?
- `EASE_IN_OUT`: ?

---

## 정답

<details>
<summary>정답 보기</summary>

**Q1.**
- `one_shot = true`: 파티클을 한 번만 방출하고 멈춤 (폭발, 수집 효과 등)
- `one_shot = false`: 계속해서 파티클을 방출 (연기, 불꽃, 마법 오라 등)

**Q2.** `explosiveness = 1.0`은 파티클을 모두 한꺼번에 방출한다. 0.0이면 수명 동안 균등하게 방출되어 폭발처럼 보이지 않는다. 폭발은 모든 파티클이 동시에 터져 나오는 느낌이어야 한다.

**Q3.** ③ — AnimationPlayer는 에디터에서 키프레임을 설정하므로 복잡한 애니메이션을 미리 확인하며 만들 수 있다. ①②④는 코드에서 동적으로 처리되는 상황이므로 Tween이 더 적합하다.

**Q4.** `EASE_OUT`은 빠르게 시작하고 끝에서 감속한다. 현실 물체가 마찰로 천천히 멈추는 것처럼 느껴져서 가장 자연스럽다. 반대로 `EASE_IN`(천천히 시작)은 "무언가 버벅이는" 느낌이 든다.

**Q5.** Tween 애니메이션이 0.5초 동안 실행되는 동안, 아이템이 아직 씬에 존재한다. `CollisionShape3D`를 비활성화하지 않으면 플레이어가 올라가는 아이템과 다시 충돌해 수집이 중복으로 발생할 수 있다.

**Q6.** `CPUParticles3D` — CPU에서 처리하므로 성능은 더 느리지만 모든 기기와 Web 빌드에서 광범위하게 지원된다. `GPUParticles3D`는 일부 저사양 GPU나 Web 환경에서 지원이 안 될 수 있다.

**Q7.** `await tween.finished`는 Tween(0.5초 동안 위로 올라가며 투명해지는 효과)이 완전히 끝날 때까지 기다린다. 완료된 후에 `queue_free()`로 안전하게 씬에서 제거한다. 이 줄 없이 바로 `queue_free()`를 호출하면 애니메이션이 끝나기도 전에 노드가 삭제된다.

**Q8.**
- `EASE_IN`: 천천히 시작 → 빠르게 끝 (가속하는 느낌)
- `EASE_OUT`: 빠르게 시작 → 천천히 끝 (감속하는 느낌, 가장 자연스러움)
- `EASE_IN_OUT`: 천천히 시작 → 빠른 중간 → 천천히 끝 (부드러운 곡선)

</details>
