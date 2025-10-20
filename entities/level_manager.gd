extends Node

@export var loaded_level:Level = preload("res://data/level_data/hub.tres")

func set_loaded_level(lvl:Level):
	loaded_level = lvl

##Loading a level will put the player in the starting room of the level.
func load_level():
	if loaded_level == null:
		assert(false,"No level loaded!")
	if get_child_count() > 0:
		for r in get_children():
			r.queue_free()
	var starting_room:Room = load(loaded_level.room_list[0]).instantiate()
	add_child(starting_room)
	starting_room.respawn_room()
	
func _ready() -> void:
	load_level()
	pass

func get_current_level() -> Room:
	return get_child(0)

##Used mainly for room transitions.
func change_rooms(room:Room):
	get_current_level().queue_free()
	add_child(room)
