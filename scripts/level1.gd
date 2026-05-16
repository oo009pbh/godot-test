extends Node3D

func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == KEY_H and event.pressed:
		GameManager.take_damage(20)

func _on_game_over() -> void:
	TransitionManager.transition_to("res://scenes/ui/game_over.tscn")
