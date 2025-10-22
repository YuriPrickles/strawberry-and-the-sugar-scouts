class_name Stopwatch
extends Node

enum TimekeepingType{
	IGT,
	RTA
}
var time:float
var stopped: bool = true
var timekeeping_type:TimekeepingType = TimekeepingType.IGT
var ignore_pauses:bool = false

func _process(delta: float) -> void:
	match timekeeping_type:
		TimekeepingType.IGT:
			process_mode = Node.PROCESS_MODE_PAUSABLE
		TimekeepingType.RTA:
			process_mode = Node.PROCESS_MODE_ALWAYS
	update_pausiness()
	if not stopped and timekeeping_type == TimekeepingType.IGT:
		time += delta

func update_pausiness():
	process_mode = Node.PROCESS_MODE_ALWAYS if ignore_pauses else Node.PROCESS_MODE_PAUSABLE

func stop():
	stopped = true
func start():
	stopped = false

func reset_time():
	time = 0.0
