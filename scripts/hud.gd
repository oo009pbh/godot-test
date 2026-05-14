extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var score_label: Label = $ScoreLabel

var _prev_health: int = 0

func _ready() -> void:
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color.RED
	health_bar.add_theme_stylebox_override("fill", fill_style)

	GameManager.health_changed.connect(_on_health_changed)
	GameManager.score_changed.connect(_on_score_changed)

	health_bar.value = GameManager.health
	score_label.text = "Score: %d" % GameManager.score
	_prev_health = GameManager.health

func _on_health_changed(new_health: int) -> void:
	var damage := _prev_health - new_health
	_prev_health = new_health
	health_bar.value = new_health
	if damage > 0:
		show_damage(damage, Vector2(110, 50))
	if new_health < 30:
		_blink_health_bar()

func _blink_health_bar() -> void:
	var tween := create_tween()
	tween.set_loops(3)
	tween.tween_property(health_bar, "modulate", Color(0.4, 0, 0, 1), 0.15)
	tween.tween_property(health_bar, "modulate", Color.WHITE, 0.15)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
	_play_score_popup()

func _play_score_popup() -> void:
	var tween := create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1)

func show_damage(amount: int, screen_position: Vector2) -> void:
	var label := Label.new()
	label.text = "-%d" % amount
	label.add_theme_color_override("font_color", Color.RED)
	label.add_theme_font_size_override("font_size", 24)
	label.position = screen_position
	add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "position:y", screen_position.y - 50, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	await tween.finished
	label.queue_free()
