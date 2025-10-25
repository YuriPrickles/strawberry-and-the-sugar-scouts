extends Control

@onready var pie_slice_counter:RichTextLabel = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/PieSliceCount
@onready var timer_text:RichTextLabel = $MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/TimerText
@onready var pie_texture:TextureRect = $MarginContainer/HBoxContainer/MarginContainer/PieTexture
@onready var pie_number:TextureRect = $MarginContainer/HBoxContainer/MarginContainer/PieNumber
@export var pie_array:Array[Texture]
@export var pie_num_array:Array[Texture]
func update_health():
	var player = State.get_player()
	pie_texture.texture = pie_array[player.health - 1] if player.health > 0 else null
	pie_number.texture = pie_num_array[player.health]
	pie_slice_counter.text = "[font_size=64]%s/%s" % [player.health, player.max_health]
	if player.health == player.max_health: pie_slice_counter.clear()

func update_timer():
	var time = LevelManager.get_session_time()
	var milliseconds = int(fposmod(time, 1) * 1000)
	var seconds = int(time) % 60
	@warning_ignore("integer_division")
	var minutes = (int(time) / 60) % 60
	@warning_ignore("integer_division")
	var hours = (int(time) / 3600)
	timer_text.text = "[font_size=32]%s%s:%s%s:%s%s:%s%s"  % [filler_zero(hours), hours, filler_zero(minutes), minutes, filler_zero(seconds), seconds, filler_zero(milliseconds,100), milliseconds]

func filler_zero(number, limit=10) -> String:
	return "" if number >= limit else "0"

func _process(_delta: float) -> void:
	update_timer()
