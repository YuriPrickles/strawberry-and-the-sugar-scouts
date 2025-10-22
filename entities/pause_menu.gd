extends Control


func _ready() -> void:
	hide()

func _on_continue_button_pressed() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false


func _on_retry_button_pressed() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await State.get_player().hurt(true)
	LevelManager.get_current_level().respawn_room()
	get_tree().paused = false
	State.reset_player_to_normal(false)


func _on_restart_button_pressed() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	Transitioner.do_transition(0.5)
	State.get_player().can_move = false
	await State.faded_in
	LevelManager.load_level()
	await State.faded_out
	State.reset_player_to_normal(false)


func _on_return_button_pressed() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	Transitioner.do_transition(0.1)
	await State.faded_in
	LevelManager.set_loaded_level(load("res://data/level_data/hub.tres"))
	LevelManager.load_level()
	await State.faded_out
	State.reset_player_to_normal()
	get_tree().paused = false
