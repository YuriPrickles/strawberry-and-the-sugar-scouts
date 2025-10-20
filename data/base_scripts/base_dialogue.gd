class_name DialogueFile
extends Resource

##A unique key where some dialogue will be stored.
##When loading a language file with duplicate dialogue keys, it will be replaced with placeholder text.
@export var dialogue_key:String
##Each element of this array would be a single "line" of dialogue.
@export_multiline var dialogue_lines:Array[String]
