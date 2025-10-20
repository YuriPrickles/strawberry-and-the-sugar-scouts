##Things you can put in levels for the player to interact with.[br]
##This is not just limited to people, these can be signs, notes, anything!
class_name NPC
extends CharacterBody3D

var player_nearby:bool
##Please do not put two interactable NPCs too close too each other[br]
##I'm begging on my knees and pleading for your mercy[br]
##I don't want to account for that possible interaction
@export var interactable:bool = true
##The mesh used for the NPC entity.
@export var npc_mesh:Mesh = null
##The text that appears when you are prompted to interact with the NPC.
@export var action_prompt_text:String = "Talk"
##The dialogue to load when talking to the NPC.
@export var dialogue_key:String

@onready var mesh_instance:MeshInstance3D = $Node3D/MeshInstance3D
@onready var action_prompt:Label3D = $ActionPrompt

func _ready() -> void:
	if npc_mesh: mesh_instance.mesh = npc_mesh

func _process(_delta: float) -> void:
	action_prompt.visible = player_nearby
	var input_text:String
	
	match State.input_type:
		State.InputType.KEYBOARD:
			#X
			var interact_event = State.get_keybinds("interact")[0]
			input_text = OS.get_keycode_string((interact_event as InputEventKey).physical_keycode)
		State.InputType.GAMEPAD:
			#X (Gamepad)
			#Will implement proper Controller Glyphs soon
			var interact_event = State.get_keybinds("interact")[0]
			input_text = "gamepad glyphs coming soon"#(interact_event).as_text()
	action_prompt.text = "[%s] %s" % [input_text,action_prompt_text]

func _on_interact_zone_body_entered(body: Node3D) -> void:
	if body is Player and interactable:
		player_nearby = true

func _on_interact_zone_body_exited(body: Node3D) -> void:
	if body is Player:
		player_nearby = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and player_nearby and !State.using_textbox:
		State.freeze_player()
		var player = State.get_player()
		var saved_rotation = player.rotation
		var saved_rotation_self = rotation
		var playerCam = player.CameraPivot
		var pos1:Vector2 = Vector2(position.x, position.z)
		var pos2:Vector2 = Vector2(player.position.x, player.position.z)
		var direction = -(pos1 - pos2)
		var tween = create_tween().set_parallel(true)
		tween.tween_property(playerCam,"rotation",  Vector3(deg_to_rad(-10),playerCam.rotation.y + deg_to_rad(60),playerCam.rotation.z),0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(player,"rotation", Vector3(0,atan2(direction.x,direction.y),0),0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"rotation", Vector3(0,atan2(direction.x,direction.y),0),0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		await State.create_textbox(Dialogue.get_dialogue(dialogue_key))
		
		var tween2 = create_tween().set_parallel(true)
		tween2.tween_property(playerCam, "rotation", State.saved_camera_rotation, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(player,"rotation", saved_rotation, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(self,"rotation", saved_rotation_self, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween2.tween_callback(State.reset_player_to_normal.bind(false))
		
