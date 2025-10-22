extends Control

@onready var pie_slice_counter:RichTextLabel = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/PieSliceCount
@onready var timer_text:RichTextLabel = $MarginContainer/HBoxContainer/MarginContainer2/VBoxContainer/TimerText

func update_health():
	var player = State.get_player()
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
