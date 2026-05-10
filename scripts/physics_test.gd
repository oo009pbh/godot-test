extends Node3D

@onready var falling_box: RigidBody3D = $FallingBox
@onready var camera: Camera3D = $Camera3D
const START_POS := Vector3(0, 15, 0)
var timer := 0.0

func _ready() -> void:
	camera.look_at(Vector3.ZERO, Vector3.UP)

func _physics_process(delta: float) -> void:
	timer += delta
	if falling_box.global_position.y < -2.0 or timer >= 6.0:
		timer = 0.0
		falling_box.global_position = START_POS
		falling_box.linear_velocity = Vector3.ZERO
		falling_box.angular_velocity = Vector3.ZERO
