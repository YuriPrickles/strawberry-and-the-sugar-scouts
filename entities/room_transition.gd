@tool
class_name RoomTransition
extends Node3D

@onready var room_trans_marker:Label3D = $RoomTransMarker
@export_file var destination_room_path:String
##Please refer to the numbers above spawn points.[br]
##These represent their indexes in the [code]spawn_points[/code] array in a [Room].
@export var spawn_point_on_entry:int

var dest_room:Room
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if destination_room_path:
		dest_room = load(destination_room_path).instantiate()
	pass # Replace with function body.

func set_room_trans_marker(number:String):
	room_trans_marker.text = "%s\nSpawnIDX:%s" % [number,spawn_point_on_entry]

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		dest_room.entered_spawn_point = dest_room.spawn_points[spawn_point_on_entry]
		get_tree().root.add_child(dest_room)
		get_parent().queue_free()
