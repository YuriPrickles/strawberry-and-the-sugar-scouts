extends MeshInstance3D
@export var mat: StandardMaterial3D
func pick_face(x: int, y: int) -> void:
	mat.uv1_offset = Vector3(0.5 * x, 0.25 * y, 0)
