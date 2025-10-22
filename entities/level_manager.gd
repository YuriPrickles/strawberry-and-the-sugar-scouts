extends Node
##Manages and loads levels and facilitates the changing of rooms via room transitions.[br]
##Also handles the creation and resetting of Sessions, which hold data like speedrun time and damage taken.

@export var loaded_level:Level = preload("res://data/level_data/hub.tres")
var current_session:Session

func set_loaded_level(lvl:Level):
	loaded_level = lvl

##Loading a level will put the player in the starting room of the level.
func load_level():
	State.reset_player_stats()
	if current_session: current_session.queue_free()
	current_session = preload("res://scripts/session.tscn").instantiate()
	get_tree().current_scene.add_child(current_session)
	current_session.damage_taken = 0
	current_session.deaths = 0
	current_session.stopwatch = preload("res://entities/stopwatch.tscn").instantiate()
	current_session.add_child(current_session.stopwatch)
	current_session.stopwatch.reset_time()
	current_session.stopwatch.start()
	if loaded_level == null:
		assert(false,"No level loaded!")
	if get_child_count() > 0:
		for r in get_children():
			r.queue_free()
	var starting_room:Room = load(loaded_level.room_list[0]).instantiate()
	add_child(starting_room)
	starting_room.respawn_room()

##Will not have any effects if the Session's stopwatch is set to RTA.
func stop_session_timer():
	current_session.stopwatch.stop()
##Will not have any effects if the Session's stopwatch is set to RTA.
func start_session_timer():
	current_session.stopwatch.start()

func set_session_timer_ignore_pauses(value:bool):
	current_session.stopwatch.ignore_pauses = value
	current_session.stopwatch.update_pausiness()
	

func get_session_time() -> float:
	return current_session.stopwatch.time

func _ready() -> void:
	
	load_level()
	pass

func get_current_level() -> Room:
	return get_child(0)

##Used mainly for room transitions.
func change_rooms(room:Room):
	get_current_level().queue_free()
	add_child(room)
