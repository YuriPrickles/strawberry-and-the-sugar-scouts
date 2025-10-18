@tool
class_name Room
extends GridMap


@export var spawn_points:Array[SpawnPoint]
var room_transitions:Array[RoomTransition]
var entered_spawn_point:SpawnPoint = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint(): return
	if spawn_points.size() <= 0:
		assert(false, "Please assign at least one Spawn Point to the room!")
	entered_spawn_point = spawn_points[0] if entered_spawn_point == null else entered_spawn_point
	State.set_spawn_point(entered_spawn_point.position)
	respawn_room()
	pass # Replace with function body.

func respawn_room():
	var player = State.get_player()
	player.position = entered_spawn_point.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		room_transitions.clear()
		for node in get_children():
			if node is RoomTransition:
				room_transitions.append(node)
		for i in spawn_points.size():
			spawn_points[i].set_spawn_marker(str(i))
		for rm in room_transitions:
			rm.set_room_trans_marker(rm.destination_room.instantiate().name)
	else:
		for i in spawn_points.size():
			spawn_points[i].set_spawn_marker("")
		for rm in room_transitions:
			rm.set_room_trans_marker("")
	pass
