extends CanvasLayer

var _overlay: ColorRect

func _ready() -> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

func change_scene(path: String, duration: float = 0.4) -> void:
	await _fade(1.0, duration)
	get_tree().change_scene_to_file(path)
	await _fade(0.0, duration)

func _fade(alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", alpha, duration)
	await tween.finished
