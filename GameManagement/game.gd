extends Node
class_name Game

signal player_changed(player: Player)

@export var stamina_start_amount = 600

var players: Array[Player]
var current_player: Player

func _ready():
	Global.game = self
	init_game()


func init_game():
	var rat_player = Player.new()
	rat_player.race = Unit.Race.Rat
	rat_player.user_controlled = true
	players.append(rat_player)
	
	var cat_player = Player.new()
	cat_player.race = Unit.Race.Cat
	cat_player.user_controlled = false
	players.append(cat_player)
	
	var dog_player = Player.new()
	dog_player.race = Unit.Race.Dog
	dog_player.user_controlled = false
	players.append(dog_player)
	
	#current_player = rat_player
	
	await get_tree().create_timer(0.1).timeout
	
	Global.main_ui.show_title("Start game", func():
		change_player(rat_player)
		Global.main_ui.show_title("Rat team")
		)


func change_player(player: Player):
	current_player = player
	emit_signal("player_changed", player)

