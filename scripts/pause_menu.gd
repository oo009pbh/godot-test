extends Control

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			_on_resume_button_pressed()
		else:
			get_tree().paused = true
			show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	GameManager.reset()
	SceneTransition.change_scene("res://scenes/level1.tscn")

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneTransition.change_scene("res://scenes/ui/main_menu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
