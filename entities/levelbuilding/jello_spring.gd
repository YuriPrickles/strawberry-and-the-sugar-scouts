extends Node3D

var bounce:bool=false
var descended:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not bounce: return
	var body = State.get_player()
	body.descending = false
	if descended:
		body.force_jump(body.JUMP_VELOCITY * 4)
	else:
		body.force_jump(body.JUMP_VELOCITY * 3)
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		descended = body.descending
		bounce = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		bounce = false
	pass # Replace with function body.
