extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	State.set_spawn_point(position)
	State.respawn_player()
	pass # Replace with function body.

	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_respawn"):
		var player = State.get_player()
		player.position = position
		pass
