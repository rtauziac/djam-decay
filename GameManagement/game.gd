extends Node2D
class_name Game

signal player_changed(player: Player)

var stamina_start_amount = 600

var players: Array[Player]
var current_player: Player
var combats_made_during_turn := Dictionary()


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
	
	await get_tree().create_timer(1).timeout
	
	#Global.main_ui.show_title("Start game", func():
		#change_player(rat_player)
		#Global.main_ui.show_title("Rat team")
		#)
	change_player(rat_player)
	Global.main_ui.show_title("Rat team")


func change_player(player: Player):
	combats_made_during_turn.clear()
	current_player = player
	emit_signal(player_changed.get_name(), player)


func combat_groups(group_a: SelectableGroup, group_b: SelectableGroup):
	if combats_made_during_turn.has(group_a.name):
		var combat_list = combats_made_during_turn[group_a.name] as Array[String]
		if combat_list.find(group_b.name) != -1:
			return
	else:
		combats_made_during_turn[group_a.name] = Array()
	
	var combat_list = combats_made_during_turn[group_a.name]
	combat_list.append(group_b.name)
	
	Global.main_ui.show_header("Combat")
	get_tree().call_group("unit", "set_physics_process", false)
	var group_a_nodes = get_tree().get_nodes_in_group(group_a.name)
	var group_b_nodes = get_tree().get_nodes_in_group(group_b.name)
	
	var group_a_count = group_a_nodes.size()
	var group_b_count = group_b_nodes.size()
	var group_a_race = group_a_nodes[0].race
	var group_b_race = group_b_nodes[0].race
	print("%s has %d units" % [group_a.name, group_a_count])
	print("%s has %d units" % [group_b.name, group_b_count])
	var group_a_hit = (group_a_count * Unit.race_advantage(group_a_race, group_b_race)) / 2
	print("%s kills %d units from %s" % [group_a.name, group_a_hit, group_b.name])
	Global.main_camera.focus_target = lerp(group_a.global_position, group_b.global_position, 0.5)
	await get_tree().create_timer(1.2).timeout
	
	var attack_direction := group_b.global_position - group_a.global_position
	for unit: Unit in group_a_nodes:
		unit.slash(attack_direction)
		await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(0.6).timeout
	
	for i_hit in group_a_hit:
		var unit: Unit = group_b_nodes[i_hit]
		unit.blood(attack_direction)
		await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(1.5).timeout
	
	var group_b_dead = get_tree().get_first_node_in_group(group_b.name) == null
	if group_b_dead:
		group_b.queue_free()
	
	if not group_b_dead:
		group_b_nodes = get_tree().get_nodes_in_group(group_b.name)
		group_b_count = group_b_nodes.size()
		print("%s has now %d units" % [group_b.name, group_b_count])
		var group_b_hit = (group_b_count * Unit.race_advantage(group_b_race, group_a_race)) / 2
		print("%s kills %d units from %s" % [group_b.name, group_b_hit, group_a.name])
		
		for unit: Unit in group_b_nodes:
			unit.slash(-attack_direction)
			await get_tree().create_timer(0.1).timeout
		
		await get_tree().create_timer(0.6).timeout
		
		for i_hit in min(group_b_hit, group_a_nodes.size()):
			var unit: Unit = group_a_nodes[i_hit]
			unit.blood(-attack_direction)
			await get_tree().create_timer(0.1).timeout
		
		await get_tree().create_timer(1.5).timeout
		
		if get_tree().get_first_node_in_group(group_a.name) == null:
			group_a.queue_free()
			
	get_tree().call_group(group_a.name, "go_to_position", group_a.global_position) # stop the walk
	get_tree().call_group("unit", "set_physics_process", true)
	Global.main_camera.focus_target = null
	Global.main_ui.hide_header()
	
