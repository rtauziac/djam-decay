extends Node2D
class_name Game

signal player_changed(player: Player)
signal combat_started()
signal combat_ended()

var stamina_start_amount = 700

var players: Array[Player]
var current_player: Player
var combats_made_during_turn := Dictionary()
var is_in_combat = false


func _ready():
	Global.game = self
	init_game()


func init_game():
	var navigation = get_parent().get_node("World/NavigationRegion2D")
	# generate obstacles randomly
	var map_size = 3000
	
	var big_obstacles = [preload("res://map/obstacles/rock.tscn"), preload("res://map/obstacles/tower.tscn")]
	var big_obstacle_count = 9
	for i_big_obstacle in big_obstacle_count:
		var i_spawn = randi_range(0, big_obstacles.size() - 1)
		var big_obstacle = big_obstacles[i_spawn].instantiate()
		navigation.add_child(big_obstacle)
		var distance = ((map_size - 400) * randf()) + 400
		var angle = i_big_obstacle * (PI * 2) / big_obstacle_count
		big_obstacle.position = Vector2(cos(angle) * distance, sin(angle) * distance)
		big_obstacle.rotation = randf() * PI * 2
	
	var small_obstacles = [preload("res://map/obstacles/tree_1.tscn"), preload("res://map/obstacles/tree_2.tscn"), preload("res://map/obstacles/tree_3.tscn"), preload("res://map/obstacles/bush_1.tscn"), preload("res://map/obstacles/bush_2.tscn"), preload("res://map/obstacles/souche.tscn")]
	var small_count = 180
	for i_big_obstacle in small_count:
		var i_spawn = randi_range(0, small_obstacles.size() - 1)
		var small_obstacle = small_obstacles[i_spawn].instantiate()
		navigation.add_child(small_obstacle)
		var distance = ((map_size - 300) * randf()) + 300
		var angle = i_big_obstacle * (PI * 2 / small_count)
		small_obstacle.position = Vector2(cos(angle) * distance, sin(angle) * distance)
	
	navigation.bake_navigation_polygon(false)
	
	var rat_player = Player.new()
	rat_player.race = Unit.Race.Rat
	rat_player.user_controlled = Global.player_1_selected_faction == Unit.Race.Rat
	players.append(rat_player)
	
	var user_player: Player = rat_player
	
	var cat_player = Player.new()
	cat_player.race = Unit.Race.Cat
	cat_player.user_controlled = Global.player_1_selected_faction == Unit.Race.Cat
	players.append(cat_player)
	
	if cat_player.user_controlled: user_player = cat_player
	
	var dog_player = Player.new()
	dog_player.race = Unit.Race.Dog
	dog_player.user_controlled = Global.player_1_selected_faction == Unit.Race.Dog
	players.append(dog_player)
	
	if dog_player.user_controlled: user_player = dog_player
	
	current_player = user_player
	
	await get_tree().create_timer(1).timeout
	
	Global.main_ui.show_title("Prepare…", func():
		change_player(current_player)
	)

func skip_turn():
	var player_index = players.find(current_player)
	var next_player_index = (player_index + 1) % players.size()
	var next_player = players[next_player_index]
	var next_player_groups = Global.groups.get_children().filter(func(a_group: SelectableGroup): return a_group.name.find(Unit.Race.keys()[next_player.race]) > -1 )
	while next_player_groups.size() == 0 and next_player != current_player:
		next_player_index = (next_player_index + 1) % players.size()
		next_player = players[next_player_index]
		next_player_groups = Global.groups.get_children().filter(func(a_group: SelectableGroup): return a_group.name.find(Unit.Race.keys()[next_player.race]) > -1 )
	if next_player == current_player:
		print("Game is done!")
	else:
		if get_user_players_alive().size() == 0:
			print("Game over…")
			Global.main_ui.show_header("You lost the game")
			Global.main_ui.show_title("Game over…")
		else:
			change_player(next_player)


func get_user_players_alive() -> Array:
	var user_players_alive = Array()
	for player in players:
		var player_groups = Global.groups.get_children().filter(func(a_group: SelectableGroup): return a_group.name.find(Unit.Race.keys()[player.race]) > -1 )
		if player_groups.size() > 0 and player.user_controlled:
			print("user player %s has some groups" % player.race)
			user_players_alive.push_front(player)
	return user_players_alive


func check_if_other_cpu_players_alive() -> bool:
	var has_any_cpu_player_alive = false
	for player in players:
		var player_groups = Global.groups.get_children().filter(func(a_group: SelectableGroup): return a_group.name.find(Unit.Race.keys()[player.race]) > -1 )
		if player_groups.size() > 0 and not player.user_controlled:
			print("user player %s has some groups" % player.race)
			has_any_cpu_player_alive = true
	return has_any_cpu_player_alive


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
		
	var group_a_nodes = get_tree().get_nodes_in_group(group_a.name)
	var group_b_nodes = get_tree().get_nodes_in_group(group_b.name)
	var group_a_race = group_a_nodes[0].race
	var group_b_race = group_b_nodes[0].race
	if group_a_race == group_b_race:
		return
	
	if is_in_combat:
		return
	
	is_in_combat = true
	emit_signal(combat_started.get_name())
	
	var combat_list = combats_made_during_turn[group_a.name]
	combat_list.append(group_b.name)
	
	Global.main_ui.show_header("Fight!")
	get_tree().call_group("unit", "set_can_walk", false)
	
	var group_a_count = group_a_nodes.size()
	var group_b_count = group_b_nodes.size()
	var group_a_hit = (group_a_count * Unit.race_advantage(group_a_race, group_b_race)) / 2
	Global.main_camera.move_to_position(group_b.global_position)
	await get_tree().create_timer(1.1).timeout
	
	var attack_direction := group_b.global_position - group_a.global_position
	for unit: Unit in group_a_nodes:
		unit.slash(attack_direction)
		await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(0.6).timeout
	
	for i_hit in min(group_a_hit, group_b_nodes.size()):
		var unit: Unit = group_b_nodes[i_hit]
		unit.blood(attack_direction)
		await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(1.5).timeout
	
	var group_b_dead = get_tree().get_first_node_in_group(group_b.name) == null
	if group_b_dead:
		group_b.free()
	
	if not group_b_dead:
		group_b_nodes = get_tree().get_nodes_in_group(group_b.name)
		group_b_count = group_b_nodes.size()
		var group_b_hit = (group_b_count * Unit.race_advantage(group_b_race, group_a_race)) / 2
		
		for unit: Unit in group_b_nodes:
			unit.slash(-attack_direction)
			await get_tree().create_timer(0.1).timeout
		
		await get_tree().create_timer(0.6).timeout
		
		group_a_nodes = get_tree().get_nodes_in_group(group_a.name)
		for i_hit in min(group_b_hit, group_a_nodes.size()):
			var unit: Unit = group_a_nodes[i_hit]
			unit.blood(-attack_direction)
			await get_tree().create_timer(0.1).timeout
		
		await get_tree().create_timer(1.5).timeout
		
		if get_tree().get_first_node_in_group(group_a.name) == null:
			group_a.free()
	
	if is_instance_valid(group_a):
		get_tree().call_group(group_a.name, "go_to_position", group_a.global_position) # stop the walk
	get_tree().call_group("unit", "set_can_walk", true)
	Global.main_ui.hide_header()
	if (Global.game.current_player.user_controlled):
		Global.main_ui.update_group_buttons()
	
	is_in_combat = false
	emit_signal(combat_ended.get_name())
	var user_players_alive = get_user_players_alive()
	if not check_if_other_cpu_players_alive() and user_players_alive.size() == 1:
		print("You win!")
		var winning_player: Player = user_players_alive[0]
		Global.main_ui.show_header("Team %s won" % Unit.Race.keys()[winning_player.race])
		Global.main_ui.show_title("You win!")
