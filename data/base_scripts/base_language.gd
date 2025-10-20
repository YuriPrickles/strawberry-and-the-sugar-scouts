@tool
class_name Language
extends Resource

@export var dialogue_array:Array[DialogueFile]

var dialogue_dict:Dictionary

func load_language():
	for dialog_file in dialogue_array:
		dialogue_dict[dialog_file.dialogue_key] = dialog_file.dialogue_lines
