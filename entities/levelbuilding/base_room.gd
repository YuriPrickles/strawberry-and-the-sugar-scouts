@tool
class_name Room
extends GridMap

##Add all your room's spawn points to this array.[br]
##This will give them their own IDs, which are their indices in the array.
##[br][br]
##For consistency, put your complimentary DefaultSpawn in index 0.
@export var spawn_points:Array[SpawnPoint]
var room_transitions:Array[RoomTransition]
##When this room is instantiated, it will be set to the spawn point in index 0.
var entered_spawn_point:SpawnPoint = null

func _ready() -> void:
	if Engine.is_editor_hint(): return
	if spawn_points.size() <= 0:
		assert(false, "Please assign at least one Spawn Point to the room!\nHow does this happen? You're given a DefaultSpawn!")
	entered_spawn_point = spawn_points[0] if entered_spawn_point == null else entered_spawn_point
	State.set_spawn_point(entered_spawn_point.position)
	respawn_room()

##Respawns the player, putting them back at the spawn point.
##[br][br]
##Also resets any non-persistent entities.
func respawn_room(also_reset_spawn:bool = false):
	var player = State.get_player()
	if also_reset_spawn: State.set_spawn_point(entered_spawn_point.position)
	player.position = State.spawn_point

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		room_transitions.clear()
		for node in get_children():
			if node is RoomTransition:
				room_transitions.append(node)
		for i in spawn_points.size():
			spawn_points[i].set_spawn_marker(str(i))
		for rm in room_transitions:
			if rm.dest_room != null:
				rm.set_room_trans_marker(rm.dest_room.name)
	else:
		for i in spawn_points.size():
			spawn_points[i].set_spawn_marker("")
		for rm in room_transitions:
			rm.set_room_trans_marker("")
	pass
