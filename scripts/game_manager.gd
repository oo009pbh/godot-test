extends Node

signal score_changed(new_score: int)
signal health_changed(new_health: int)
signal game_over
signal level_changed(new_level: int)

const MAX_HEALTH: int = 100

var score: int = 0
var health: int = MAX_HEALTH
var current_level: int = 1

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	health_changed.emit(health)
	if health <= 0:
		game_over.emit()

func heal(amount: int) -> void:
	health = min(MAX_HEALTH, health + amount)
	health_changed.emit(health)

func next_level() -> void:
	current_level += 1
	level_changed.emit(current_level)

func reset() -> void:
	score = 0
	health = MAX_HEALTH
	current_level = 1
	score_changed.emit(score)
	health_changed.emit(health)
	level_changed.emit(current_level)
