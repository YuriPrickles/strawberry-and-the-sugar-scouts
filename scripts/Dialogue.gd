extends Node

func _ready() -> void:
	pass # Replace with function body.

##From a dialogue key, returns its corresponding dialogue array.
func get_dialogue(key:String) -> Array[String]:
	return State.loaded_language_file.dialogue_dict.get(key,[])
