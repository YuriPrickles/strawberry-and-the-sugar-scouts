extends Control

@onready var anim_player = $AnimationPlayer
var doing_transition = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func do_transition(speed:float = 1.0):
	move_to_front()
	doing_transition = true
	anim_player.play("fade_in",-1,speed)
	await anim_player.animation_finished
	State.faded_in.emit()
	anim_player.play("fade_out",-1,speed)
	State.faded_out.emit()
	await anim_player.animation_finished
	doing_transition = false
