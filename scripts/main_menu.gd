extends Control

@onready var _continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	call_deferred("_init_mouse")
	_continue_button.disabled = not SaveManager.has_save()

func _init_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_button_pressed() -> void:
	TransitionManager.transition_to("res://scenes/level1.tscn")

func _on_continue_button_pressed() -> void:
	SaveManager.load_save()
	TransitionManager.transition_to("res://scenes/level1.tscn")
