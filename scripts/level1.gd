extends Node3D

func _ready() -> void:
	GameManager.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	SceneTransition.change_scene("res://scenes/ui/game_over.tscn")
