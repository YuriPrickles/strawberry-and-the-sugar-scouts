extends Node
##The helpful little general-purpose singleton/autoload/global class.[br][br]
##If something is not big enough to need its own script in another place and is a common function, it goes here.

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

##The player will not be able to move the camera if this is true.
var no_cam_control:bool
##Used to save the camera rotation before messing with it, so that there's somewhere for it to return.
var saved_camera_rotation:Vector3

##Unused. I really wanted to use the deprecated thing for documentation heehee
##@deprecated
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

##Used for respawning the player without resetting the room (For unrecoverable falls)
func respawn_player():
	LevelManager.set_session_timer_ignore_pauses(true)
	get_tree().paused = true
	unpausable = true
	var tween = create_tween()
	tween.tween_property(get_player(),"position",Vector3(get_player().position.x,get_spawn_point().y,get_player().position.z),1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SPRING)
	await tween.finished
	var tween2 = create_tween()
	tween2.tween_property(get_player(),"position",Vector3(get_spawn_point().x,get_player().position.y,get_spawn_point().z),1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	await tween2.finished
	unpausable = false
	get_tree().paused = false
	LevelManager.set_session_timer_ignore_pauses(false)

##Restores the player's health.
func reset_player_stats():
	get_player().health = get_player().max_health
	HUD.update_health()

##Save the camera rotation. Useful if needed to tween back to it later.
func save_camera_rotation():
	saved_camera_rotation = get_player().CameraPivot.rotation

##Stop camera and player movement and disallow pausing.
func freeze_player():
	get_player().can_move = false
	no_cam_control = true
	unpausable = true

##This function will return control to the Player and the camera.[br]
##Use [code]false[/code] for when you just messed with the camera to return it to a neutral position.
func reset_player_to_normal(reset_cam_rotation:bool = true):
	get_player().can_move = true
	if reset_cam_rotation: get_player().CameraPivot.rotation.y = deg_to_rad(0)
	no_cam_control = false
	unpausable = false
	using_textbox = false
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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
		if get_tree().paused and not PauseMenu.visible:
			get_tree().paused = true
			PauseMenu.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

##Returns all InputEvents of the action.
func get_keybinds(action_name:String) -> Array[InputEvent]:
	for bind in InputMap.get_actions():
		if bind == action_name:
			return InputMap.action_get_events(bind)
	return [null]

##Remember to do [code]State.using_textbox = false[/code] on your own![br]
##This is to allow more flexibility on making sure that no janky textbox rereading loop happens.
##[br][br]
##For example, the State singleton has it in the [method State.reset_player_to_normal] function.
func create_textbox(dialogue:Array[String]):
	using_textbox = true
	for line in dialogue:
		var textbox = (preload("res://entities/textbox.tscn").instantiate() as Textbox)
		get_tree().root.add_child(textbox)
		textbox.displayText(line)
		await textbox_close
	
