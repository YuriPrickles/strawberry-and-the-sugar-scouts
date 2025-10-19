extends Node

@warning_ignore("unused_signal")
signal faded_in
@warning_ignore("unused_signal")
signal faded_out

var unpausable:bool
var any_ui_open:bool

var no_cam_control:bool

var spawn_point:Vector3

func get_player() -> Player:
	return GlobalPlayer

func set_spawn_point(spawn:Vector3):
	spawn_point = spawn
func get_spawn_point():
	return spawn_point
func respawn_player():
	get_player().position = get_spawn_point()

func reset_player_to_normal(reset_cam_rotation:bool = true):
	get_player().can_move = true
	if reset_cam_rotation: get_player().CameraPivot.rotation.y = deg_to_rad(0)
	no_cam_control = false
	unpausable = false
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_player()._init()
	pass # Replace with function body.

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if Transitioner.doing_transition: return
		if any_ui_open: return
		PauseMenu.visible = !PauseMenu.visible if not unpausable else false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if PauseMenu.visible else Input.MOUSE_MODE_CAPTURED
		get_tree().paused = !get_tree().paused if not unpausable else false
