extends Node

const SAVE_PATH = "user://save.json"

func save() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var player_pos := Vector3.ZERO
	if player:
		player_pos = player.global_position

	var save_data := {
		"score": GameManager.score,
		"health": GameManager.health,
		"current_level": GameManager.current_level,
		"position": {
			"x": player_pos.x,
			"y": player_pos.y,
			"z": player_pos.z
		},
		"timestamp": Time.get_unix_time_from_system()
	}
	save_data["checksum"] = _create_checksum(save_data)

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
	else:
		push_error("세이브 파일을 열 수 없습니다: " + SAVE_PATH)

func load_save() -> bool:
	if not has_save():
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false

	var json_text := file.get_as_text()
	file.close()

	var save_data = JSON.parse_string(json_text)
	if save_data == null:
		push_error("세이브 파일 파싱 실패")
		return false

	var stored_checksum: String = save_data.get("checksum", "")
	save_data.erase("checksum")
	if _create_checksum(save_data) != stored_checksum:
		push_error("세이브 파일이 변조되었습니다")
		return false

	GameManager.score = save_data.get("score", 0)
	GameManager.health = save_data.get("health", 100)
	GameManager.current_level = save_data.get("current_level", 1)

	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _create_checksum(data: Dictionary) -> String:
	return JSON.stringify(data).sha256_text()
