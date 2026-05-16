# Ch15 Q&A

---

## Q1. 세이브 데이터를 서버에 저장하고 불러오는 클라우드 세이브는 어떻게 구현하나?

**로컬 파일 대신 HTTP 요청으로 서버 API를 호출하는 방식으로 교체하면 된다.**

지금 우리 `save_manager.gd`는 `FileAccess`로 `user://save.json`에 쓰고 읽는다.
클라우드 세이브는 이 부분만 HTTP 요청으로 바꾸면 된다 — 나머지 구조(체크섬, 데이터 딕셔너리)는 동일하게 유지.

**비유:** 지금은 집 서랍에 메모를 넣는 것, 클라우드 세이브는 그 메모를 우체국(서버)에 보내서 보관하는 것.
어디서 접속해도 같은 메모를 꺼낼 수 있다.

**Godot에서 HTTP 요청 방식:**

```gdscript
# save_manager.gd (클라우드 버전)
extends Node

const API_URL = "https://your-backend.com/save"
var _http: HTTPRequest

func _ready() -> void:
    _http = HTTPRequest.new()
    add_child(_http)

func save_to_cloud(user_token: String) -> void:
    var save_data = {
        "score": GameManager.score,
        "health": GameManager.health,
        "current_level": GameManager.current_level,
    }
    var body = JSON.stringify(save_data)
    var headers = [
        "Content-Type: application/json",
        "Authorization: Bearer " + user_token  # 유저 인증 토큰
    ]
    _http.request(API_URL, headers, HTTPClient.METHOD_POST, body)
    await _http.request_completed
    # → 서버가 { "ok": true } 응답 반환

func load_from_cloud(user_token: String) -> bool:
    var headers = ["Authorization: Bearer " + user_token]
    _http.request(API_URL, headers, HTTPClient.METHOD_GET)
    var result = await _http.request_completed
    # result[3] = 응답 바이트 배열
    var json_text = result[3].get_string_from_utf8()
    var save_data = JSON.parse_string(json_text)
    if save_data == null:
        return false
    GameManager.score = save_data.get("score", 0)
    GameManager.health = save_data.get("health", 100)
    return true
```

**서버 쪽(백엔드)에서 필요한 것:**

| 역할 | 예시 기술 |
|------|-----------|
| API 서버 | Node.js(Express), Python(FastAPI), Go |
| DB | PostgreSQL, Firebase Firestore, Supabase |
| 인증 | JWT 토큰, Firebase Auth, Supabase Auth |

**실용적인 선택지 (소규모 인디 게임):**
- **Supabase** — DB + 인증 + REST API가 한 번에 제공되는 오픈소스 Firebase 대안. 무료 티어 충분.
- **Firebase** — Google의 BaaS(Backend as a Service). Godot 전용 플러그인 존재.

**흐름 정리:**
1. 게임 시작 → 로그인 → `user_token` 발급
2. Save 버튼 → `save_to_cloud(user_token)` → 서버 DB에 저장
3. Continue 버튼 → `load_from_cloud(user_token)` → 서버 DB에서 불러오기

로컬 저장과 병행하면 오프라인에서도 플레이 가능하고, 온라인 접속 시 동기화하는 하이브리드 방식도 흔하다.

---

## Q2. 웹에서는 JWT 방식으로 유저 로그인을 구현하는데, Godot에서는 주로 어떻게 하지?

**Godot도 JWT를 그대로 쓴다 — 웹과 흐름이 완전히 같고, 토큰을 파일에 저장하는 것만 다르다.**

웹에서는 로그인 후 JWT를 `localStorage`나 쿠키에 보관한다.
Godot에서는 그 역할을 `user://token.cfg` 같은 로컬 파일이 대신한다.
토큰을 HTTP 헤더에 실어 서버에 보내는 방식은 완전히 동일하다.

**로그인 흐름:**

```gdscript
# auth_manager.gd (Autoload)
extends Node

const API_URL = "https://your-backend.com"
const TOKEN_PATH = "user://token.cfg"

var _token: String = ""
var _http: HTTPRequest

func _ready() -> void:
    _http = HTTPRequest.new()
    add_child(_http)
    _load_token()  # 앱 시작 시 저장된 토큰 복원

func login(email: String, password: String) -> bool:
    var body = JSON.stringify({ "email": email, "password": password })
    var headers = ["Content-Type: application/json"]
    _http.request(API_URL + "/login", headers, HTTPClient.METHOD_POST, body)
    var result = await _http.request_completed

    var data = JSON.parse_string(result[3].get_string_from_utf8())
    if data == null or not data.has("token"):
        return false

    _token = data["token"]   # JWT 수령
    _save_token()            # 파일에 보관 (다음 실행 시 재사용)
    return true

func get_auth_header() -> String:
    return "Authorization: Bearer " + _token

func is_logged_in() -> bool:
    return _token != ""

func _save_token() -> void:
    var config := ConfigFile.new()
    config.set_value("auth", "token", _token)
    config.save(TOKEN_PATH)

func _load_token() -> void:
    var config := ConfigFile.new()
    if config.load(TOKEN_PATH) == OK:
        _token = config.get_value("auth", "token", "")
```

**클라우드 세이브 호출 시:**

```gdscript
# save_manager.gd에서
func save_to_cloud() -> void:
    var headers = [
        "Content-Type: application/json",
        AuthManager.get_auth_header()  # JWT 헤더 자동 삽입
    ]
    _http.request(API_URL + "/save", headers, HTTPClient.METHOD_POST, body)
```

**Godot에서 자주 쓰는 인증 방식 비교:**

| 방식 | 난이도 | 적합한 경우 |
|------|--------|-------------|
| JWT (직접 구현) | 중 | 자체 백엔드가 있을 때 |
| Firebase Auth | 하 | 빠른 개발, Google/이메일 로그인 |
| Supabase Auth | 하 | Firebase 대안, PostgreSQL 기반 |
| Steam / Epic SDK | 중 | 스팀 배포 게임 (플랫폼 인증) |

스팀 배포를 목표로 한다면 Steam SDK가 이미 유저 인증을 처리해주기 때문에 별도 로그인 UI가 필요 없다.
인디 게임 초기엔 Supabase Auth가 가장 빠른 선택이다.

---
