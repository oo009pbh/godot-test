extends Node3D

@export var models_path: String = "res://assets/models/"
@export var grid_columns: int = 3
@export var grid_spacing: float = 3.0

func _ready() -> void:
	_place_models()

func _place_models() -> void:
	var dir := DirAccess.open(models_path)
	if dir == null:
		push_error("AssetPlacer: 폴더를 열 수 없음 — " + models_path)
		return

	var glb_files: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".glb"):
			glb_files.append(models_path + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	if glb_files.is_empty():
		push_warning("AssetPlacer: .glb 파일 없음 — " + models_path)
		return

	print("AssetPlacer: %d개 모델 배치 시작" % glb_files.size())

	for i in glb_files.size():
		var row := i / grid_columns
		var col := i % grid_columns
		var pos := Vector3(col * grid_spacing, 0.0, row * grid_spacing)
		_spawn_model(glb_files[i], pos)

func _spawn_model(path: String, pos: Vector3) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("AssetPlacer: 로드 실패 — " + path)
		return

	var static_body := StaticBody3D.new()
	static_body.position = pos
	add_child(static_body)

	var model := packed.instantiate()
	static_body.add_child(model)

	var mesh_instance := _find_mesh_instance(model)
	if mesh_instance != null and mesh_instance.mesh != null:
		var collision := CollisionShape3D.new()
		collision.shape = mesh_instance.mesh.create_convex_shape(true, true)
		static_body.add_child(collision)
		print("AssetPlacer: '%s' 배치 완료 (convex 충돌)" % path.get_file())
	else:
		# 메시를 못 찾으면 1×2×1 박스로 대체
		var collision := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(1.0, 2.0, 1.0)
		collision.shape = box
		static_body.add_child(collision)
		push_warning("AssetPlacer: '%s' 메시 없음, 박스 충돌 사용" % path.get_file())

func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node as MeshInstance3D
	for child in node.get_children():
		var result := _find_mesh_instance(child)
		if result != null:
			return result
	return null
