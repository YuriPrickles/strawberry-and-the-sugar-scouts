@tool
class_name SpawnPoint
extends Node3D

@onready var spawn_marker:Label3D = $SpawnMarker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func set_spawn_marker(number:String):
	spawn_marker.text = number
