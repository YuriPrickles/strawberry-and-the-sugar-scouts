extends ColorRect

@onready var anim_player = $AnimationPlayer
@onready var speedrun_text = $MarginContainer/VBoxContainer/SpeedrunText
@onready var pies_lost_text = $MarginContainer/VBoxContainer/PiesLostText

var final_milliseconds = 0
var final_seconds = 0
var final_minutes = 0
var final_hours = 0
var rank = "???"
var pies_lost = 0
var slices_lost = 0

func _ready() -> void:
	State.any_ui_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	anim_player.play("appear")
	await anim_player.animation_finished
	tween_stats()
	pass

func _process(_delta: float) -> void:
	speedrun_text.text = "[font_size=48]Time: %s%s:%s%s:%s%s:%s%s [font_size=32](%s)"% [filler_zero(final_hours), final_hours, filler_zero(final_minutes), final_minutes, filler_zero(final_seconds), final_seconds, filler_zero(final_milliseconds,100), final_milliseconds, rank]
	pies_lost_text.text = "[font_size=48]Pies Lost: %s [font_size=32](%s %s)" % [pies_lost, slices_lost, "slice" if slices_lost == 1 else "slices"]
func filler_zero(number, limit=10) -> String:
	return "" if number >= limit else "0"
	
func tween_stats():
	var time = LevelManager.get_session_time()
	var total_milliseconds = int(fposmod(time, 1) * 1000)
	var total_seconds = int(time) % 60
	@warning_ignore("integer_division")
	var total_minutes = (int(time) / 60) % 60
	@warning_ignore("integer_division")
	var total_hours = (int(time) / 3600)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "final_hours",total_hours, get_time_tween_duration(total_hours))
	tween.chain().tween_property(self, "final_minutes",total_minutes, get_time_tween_duration(total_minutes))
	tween.chain().tween_property(self, "final_seconds",total_seconds, get_time_tween_duration(total_seconds))
	tween.chain().tween_property(self, "final_milliseconds",total_milliseconds, get_time_tween_duration(total_milliseconds))
	await tween.finished
	await calculate_rank(total_hours,total_minutes,total_seconds)
	
	await get_tree().create_timer(1).timeout
	var tween2 = create_tween()
	tween2.tween_property(self,"pies_lost",LevelManager.current_session.deaths,get_time_tween_duration(LevelManager.current_session.deaths))
	tween2.chain().tween_property(self,"slices_lost",LevelManager.current_session.damage_taken,get_time_tween_duration(LevelManager.current_session.damage_taken))
	

func calculate_rank(temp_hours, temp_minutes, temp_seconds):
	await get_tree().create_timer(1).timeout
	var rank_dict:Dictionary[Level.SpeedrunRanks,SpeedrunData] = LevelManager.loaded_level.speedrun_bonus
	for record:Level.SpeedrunRanks in rank_dict.keys():
		var speedrun_data:SpeedrunData = rank_dict.get(record)
		var player_time = (temp_hours * 3600) + (temp_minutes * 60) + temp_seconds
		var total_speedrun_time = (speedrun_data.hours * 3600) + (speedrun_data.minutes * 60) + speedrun_data.seconds
		if ((player_time == total_speedrun_time and final_milliseconds == 0) or 
			(player_time < total_speedrun_time)):
			match record:
				Level.SpeedrunRanks.Gold:
					rank = "Gold"
				Level.SpeedrunRanks.Silver:
					rank = "Silver"
				Level.SpeedrunRanks.Copper:
					rank = "Copper"
			return
	rank = ""

func get_time_tween_duration(value) -> float:
	return 1 if value != 0 else 0

func _on_return_button_pressed() -> void:
	$MarginContainer/VBoxContainer/ReturnButton.disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Transitioner.do_transition(0.1)
	await State.faded_in
	LevelManager.set_loaded_level(load("res://data/level_data/hub.tres"))
	LevelManager.load_level()
	hide()
	await State.faded_out
	State.reset_player_to_normal()
	State.any_ui_open = false
	queue_free()
