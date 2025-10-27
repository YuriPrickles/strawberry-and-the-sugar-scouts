extends Node3D

var no_bounce:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.velocity = Vector3.ZERO
		if body.descending:
			body.descending = false
			body.force_jump(body.JUMP_VELOCITY * 4)
		else:
			body.force_jump(body.JUMP_VELOCITY * 3)
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
