extends Area3D

func _ready() -> void:
	add_to_group("coin")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	$AnimationPlayer.stop()
	$CollisionShape3D.set_deferred("disabled", true)
	GameManager.add_score(10)

	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 1.0, 0.4)
	tween.parallel().tween_property($MeshInstance3D, "transparency", 1.0, 0.4)
	await tween.finished
	queue_free()
