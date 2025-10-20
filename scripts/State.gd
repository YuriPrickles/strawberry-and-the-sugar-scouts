extends Node

@warning_ignore("unused_signal")
signal faded_in
@warning_ignore("unused_signal")
signal faded_out
signal textbox_close

enum InputType{
	KEYBOARD,
	GAMEPAD
}

var unpausable:bool
var any_ui_open:bool

var no_cam_control:bool
var saved_camera_rotation:Vector3
var interacting_with:Variant

var spawn_point:Vector3

var input_type:InputType

var loaded_language_file:Language = preload("res://data/languages/English.tres")
var using_textbox = false

func get_player() -> Player:
	return GlobalPlayer

func set_spawn_point(spawn:Vector3):
	spawn_point = spawn
func get_spawn_point():
	return spawn_point
func respawn_player():
	get_player().position = get_spawn_point()

func save_camera_rotation():
	saved_camera_rotation = get_player().CameraPivot.rotation

func freeze_player():
	get_player().can_move = false
	no_cam_control = true
	unpausable = true
func reset_player_to_normal(reset_cam_rotation:bool = true):
	get_player().can_move = true
	if reset_cam_rotation: get_player().CameraPivot.rotation.y = deg_to_rad(0)
	no_cam_control = false
	unpausable = false
	using_textbox = false
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loaded_language_file.load_language()
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_player()._init()

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		input_type = InputType.KEYBOARD
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		input_type = InputType.GAMEPAD
	if Input.is_action_just_pressed("pause"):
		if Transitioner.doing_transition: return
		if any_ui_open: return
		PauseMenu.visible = !PauseMenu.visible if not unpausable else false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if PauseMenu.visible else Input.MOUSE_MODE_CAPTURED
		get_tree().paused = !get_tree().paused if not unpausable else false

##Returns all InputEvents of the action.
func get_keybinds(action_name:String) -> Array[InputEvent]:
	for bind in InputMap.get_actions():
		if bind == action_name:
			return InputMap.action_get_events(bind)
	return [null]

##Remember to do [code]State.using_textbox = false[/code] on your own![br]
##This is to allow more flexibility on making sure that no janky textbox rereading loop happens.
##[br][br]
##For example, the [NPC] class puts [code]State.using_textbox = false[/code] in a tween callback.
func create_textbox(dialogue:Array[String]):
	using_textbox = true
	for line in dialogue:
		var textbox = (preload("res://entities/textbox.tscn").instantiate() as Textbox)
		get_tree().root.add_child(textbox)
		textbox.displayText(line)
		await textbox_close
	
