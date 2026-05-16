extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 3.0
@export var max_enemies: int = 5

var _spawn_timer: float = 0.0

func _physics_process(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval
		_try_spawn()

func _try_spawn() -> void:
	if enemy_scene == null:
		return
	var current_enemies := get_tree().get_nodes_in_group("enemy").size()
	if current_enemies >= max_enemies:
		return

	var spawn_points := get_children()
	if spawn_points.is_empty():
		return

	var point: Node3D = spawn_points.pick_random()
	var enemy := enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = point.global_position
