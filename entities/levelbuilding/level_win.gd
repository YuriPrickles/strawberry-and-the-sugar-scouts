@tool
extends Node3D

##The mesh for the dessert used to represent the end of the level.
@export var dessert_mesh:Mesh = preload("res://meshes/level_win_placeholder.tres")

@onready var mesh_instance = $MeshInstance3D

var touched:bool

func _ready() -> void:
	mesh_instance.mesh = dessert_mesh

func _process(_delta: float) -> void:
	if touched:
		var player = State.get_player()
		player.CameraPivot.rotation.y += deg_to_rad(2.4)
		

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player and not touched:
		var player = State.get_player()
		player.can_move = false
		State.no_cam_control = true
		State.unpausable = true
		touched = true
		await get_tree().create_timer(2).timeout
		get_tree().root.add_child(preload("res://entities/score_screen.tscn").instantiate())
