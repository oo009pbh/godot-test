extends Control

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif what == NOTIFICATION_UNPAUSED:
		hide()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	SceneTransition.change_scene("res://scenes/level1.tscn")

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneTransition.change_scene("res://scenes/ui/main_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
