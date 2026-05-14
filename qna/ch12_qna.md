# Ch12 Q&A

---

## Q1. ESC를 눌렀는데 일시정지 메뉴가 왜 안 나왔나?

**`PROCESS_MODE_ALWAYS` 노드는 "멈춤" 상태에 들어가지 않기 때문에 `NOTIFICATION_PAUSED`를 받지 못한다.**

비유하자면 이렇다: 게임 전체가 "정지" 버튼을 누른 상태여도,
심판(PROCESS_MODE_ALWAYS 노드)은 멈추지 않고 계속 뛰어다닌다.
그런데 `NOTIFICATION_PAUSED`는 "방금 멈춰진 선수"에게만 전달되는 메시지다.
멈춘 적 없는 심판은 그 메시지를 받지 못한다.

```gdscript
# ❌ 잘못된 접근 — ALWAYS 노드는 이 알림을 받지 않는다
func _notification(what: int) -> void:
    if what == NOTIFICATION_PAUSED:
        show()  # 절대 실행되지 않음
```

올바른 해결책: 입력 이벤트로 직접 감지한다.

```gdscript
# ✅ 올바른 접근
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_tree().paused = true
        show()
```

---

## Q2. 전역 키 단축키(ESC 등)는 `_input`과 `_unhandled_input` 중 어느 걸 써야 하나?

**전역 단축키는 `_unhandled_input`을 써야 UI 버튼 등과 충돌하지 않는다.**

두 함수의 호출 순서는 이렇다:

```
키 입력 발생
    ↓
① _input (모든 처리 중인 노드에 전달)
    ↓
② GUI Control이 이벤트 소비 (버튼 클릭, 포커스 이동 등)
    ↓
③ _unhandled_input (소비되지 않은 이벤트만 전달)
```

UI 위젯(Button 등)이 ESC를 먹어버리면 `_input`을 쓰면 충돌이 날 수 있다.
`_unhandled_input`은 "아무도 처리 안 한 입력"만 받으므로 전역 단축키에 안전하다.

또한 파라미터 타입은 반드시 `InputEvent`로 써야 한다:

```gdscript
# ✅ 올바른 시그니처
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        ...

# ❌ 타입을 더 구체적으로 쓰면 Godot이 함수를 인식 못 할 수 있다
func _unhandled_key_input(event: InputEventKey) -> void:
    ...
```

그리고 액션 이름 `"ui_cancel"` 은 Godot 기본 설정에서 ESC 에 매핑된 액션이다.
직접 keycode를 비교하는 것보다 훨씬 안전하다.

---

## Q3. 메인 메뉴에서 마우스가 안 보이는 이유는?

**`_ready()` 시점에 마우스 모드를 설정해도 macOS에서는 창이 준비되기 전이라 적용이 씹힐 수 있다.**

타이밍 문제다. `_ready()`는 씬이 트리에 추가된 직후 실행되는데,
macOS에서는 그 시점에 윈도우 포커스가 아직 완전히 넘어오지 않아서
마우스 모드 설정이 OS에 의해 덮어씌워질 수 있다.

해결책: 즉시 설정 + `call_deferred`로 한 프레임 뒤에 한 번 더 설정한다.

```gdscript
# main_menu.gd
func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)   # 즉시
    call_deferred("_init_mouse")                      # 첫 프레임 이후에 한 번 더

func _init_mouse() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
```

`call_deferred`는 "지금 하던 거 다 끝내고 나서 이 함수 호출해줘"라는 뜻이다.
첫 프레임이 완전히 처리된 뒤에 실행되므로 창 포커스 타이밍 문제를 피할 수 있다.

또한 Autoload인 `GameManager._ready()`에서도 미리 한 번 설정해두면 더 안전하다:

```gdscript
# game_manager.gd
func _ready() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # 가장 이른 시점에 설정
```

---
