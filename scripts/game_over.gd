extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$CenterContainer/VBoxContainer/ScoreLabel.text = "Score: %d" % GameManager.score

func _on_retry_button_pressed() -> void:
	GameManager.reset()
	TransitionManager.transition_to("res://scenes/level1.tscn")
