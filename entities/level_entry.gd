extends Node3D

@export var level_to_load:Level

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		Transitioner.do_transition(0.2)
		State.get_player().can_move = false
		await State.faded_in
		LevelManager.set_loaded_level(level_to_load)
		LevelManager.load_level()
		await State.faded_out
		State.get_player().can_move = true
