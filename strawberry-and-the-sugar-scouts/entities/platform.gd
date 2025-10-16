@tool
extends StaticBody3D

@onready var collision_shape = $CollisionShape3D
@onready var mesh_inst = $MeshInstance3D
@export var platform_size:Vector3 = Vector3.ONE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var true_shape:BoxShape3D = collision_shape.shape
	var true_mesh:BoxMesh = mesh_inst.mesh
	true_shape.size = platform_size
	true_mesh.size = platform_size
	collision_shape.shape = true_shape
	mesh_inst.mesh = true_mesh
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
