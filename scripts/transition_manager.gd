extends CanvasLayer

var is_transitioning: bool = false
var _overlay: ColorRect

func _ready() -> void:
	layer = 128
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

func transition_to(scene_path: String, fade_time: float = 0.4) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, fade_time)
	await tween.finished

	get_tree().change_scene_to_file(scene_path)

	tween = create_tween()
	tween.tween_property(_overlay, "color:a", 0.0, fade_time)
	await tween.finished

	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
