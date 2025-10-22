class_name Textbox
extends Control

var textSpeed = .02
var unclosable = false
var soundFreq = 3

@onready var label = $MarginContainer/ColorRect/MarginContainer/Text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	State.any_ui_open = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(_event: InputEvent) -> void:
	if unclosable:
		return
	if ((Input.is_action_just_pressed("interact"))
	):
		if label.get_visible_characters() >= label.get_total_character_count():
			State.any_ui_open = false
			State.textbox_close.emit()
			queue_free()
		else:
			label.set_visible_characters(label.get_total_character_count() + 1)
	pass
func displayText(text, defaultBBCode=true):
	move_to_front()
	show()
	label.clear()
	if defaultBBCode:
		label.append_text("[font_size=40]")
	label.append_text(text)
	label.set_visible_characters(0)
	while label.get_visible_characters() < label.get_total_character_count():
		await get_tree().create_timer(textSpeed).timeout
		if label.get_visible_characters() % soundFreq == 0 || label.get_visible_characters() == 1 && label.get_total_character_count() < 3:
			pass #insert playSound function coming soon
		label.set_visible_characters(label.get_visible_characters() + 1)
