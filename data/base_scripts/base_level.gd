class_name Level
extends Resource

##The room in index 0 is considered to be the "default" or "starter" room.
@export_file("*.tscn") var room_list:Array[String]

enum SpeedrunRanks{
	Gold,
	Silver,
	Copper
}
##When making your Level resource file, be sure to edit these to have speedrun time goals.
@export var speedrun_bonus:Dictionary[SpeedrunRanks,SpeedrunData] = {
	SpeedrunRanks.Gold: null,
	SpeedrunRanks.Silver: null,
	SpeedrunRanks.Copper: null
}
