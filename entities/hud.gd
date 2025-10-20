extends Control

@onready var pie_slice_counter:RichTextLabel = $MarginContainer/HBoxContainer/MarginContainer/PieSliceCount

func update_health():
	var player = State.get_player()
	pie_slice_counter.text = "[font_size=64]%s/%s" % [player.health, player.max_health]
	if player.health == player.max_health: pie_slice_counter.clear()
