extends Control

@onready var _continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var _version_label: Label = $VersionLabel

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	call_deferred("_init_mouse")
	_continue_button.disabled = not SaveManager.has_save()
	var version: String = ProjectSettings.get_setting("application/config/version", "")
	_version_label.text = "v" + version

func _init_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_button_pressed() -> void:
	TransitionManager.transition_to("res://scenes/level1.tscn")

func _on_continue_button_pressed() -> void:
	SaveManager.load_save()
	TransitionManager.transition_to("res://scenes/level1.tscn")
