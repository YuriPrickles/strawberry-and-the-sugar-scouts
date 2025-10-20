##Please do not put two interactable NPCs too close too each other..
class_name NPC
extends CharacterBody3D

var player_nearby:bool
##Please do not put two interactable NPCs too close too each other..
@export var interactable:bool = true
@export var npc_mesh:Mesh = null

@onready var mesh_instance:MeshInstance3D = $Node3D/MeshInstance3D
@onready var action_prompt:Label3D = $ActionPrompt

func _ready() -> void:
	if npc_mesh: mesh_instance.mesh = npc_mesh

func _process(_delta: float) -> void:
	action_prompt.visible = player_nearby
	action_prompt.text = "Talk"

func _on_interact_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		player_nearby = true

func _on_interact_zone_body_exited(body: Node3D) -> void:
	if body is Player:
		player_nearby = false
