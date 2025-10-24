@tool
extends Node3D

var will_hurt = true
@onready var kill_area:Area3D = $Area3D
@export var trigger_size:Vector3 = Vector3.ONE
@export_tool_button("Update Size in Editor") var update_size = scale_kill_area

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale_kill_area(trigger_size)

func scale_kill_area(size:Vector3):
	kill_area.scale = size

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player and will_hurt and State.get_player().inv_frames_timer.is_stopped():
		body.hurt(true)
		will_hurt = false
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	will_hurt = true
	pass # Replace with function body.
