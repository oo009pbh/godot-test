extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	queue_free()
