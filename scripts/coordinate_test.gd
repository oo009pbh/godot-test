extends Node3D

func _ready():
	$Camera3D.position = Vector3(6, 5, 6)
	$Camera3D.look_at(Vector3(1.5, 1.5, 1.5))

func _process(delta: float):
	$XSphere.position.x += 1.0 * delta
	if $XSphere.position.x >= 6.0:
		$XSphere.position.x = 0.0