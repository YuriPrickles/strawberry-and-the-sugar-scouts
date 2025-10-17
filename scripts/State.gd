extends Node

var spawn_point

func get_player() -> Player:
	return GlobalPlayer

func set_spawn_point(spawn:Vector3):
	spawn_point = spawn
func get_spawn_point():
	return spawn_point
func respawn_player():
	get_player().position = get_spawn_point()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_player()._init()
	pass # Replace with function body.
