extends Node
class_name Game

var current_player: Player

func _ready():
	Global.game = self
	current_player = Player.new()
