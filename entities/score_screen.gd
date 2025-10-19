extends ColorRect

@onready var anim_player = $AnimationPlayer
func _ready() -> void:
	State.any_ui_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	anim_player.play("appear")
	pass

func _on_return_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Transitioner.do_transition(0.1)
	await State.faded_in
	LevelManager.set_loaded_level(load("res://data/level_data/hub.tres"))
	LevelManager.load_level()
	hide()
	await State.faded_out
	State.reset_player_to_normal()
	State.any_ui_open = false
	queue_free()
