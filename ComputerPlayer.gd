extends Node


func _on_game_player_changed(player: Player):
	if player.user_controlled:
		return
	
	var groups = Global.groups.get_children()
	var player_groups = groups.filter(func(group): return player.race == group.race)
	var enemy_groups = groups.filter(func(group): return player.race != group.race)
	for player_group: SelectableGroup in player_groups:
		if enemy_groups.size() > 0:
			player_group.emit_wants_to_be_selected()
			Global.main_camera.focus_target = player_group
			await get_tree().create_timer(1.5).timeout
			var closest_distance = 99999
			var closest_group = enemy_groups[0]
			for enemy_group in enemy_groups:
				if is_instance_valid(enemy_group) == false or is_instance_valid(player_group) == false:
					continue
				
				if player_group.global_position.distance_to(enemy_group.global_position) < closest_distance:
					closest_distance = player_group.global_position.distance_to(enemy_group.global_position)
					closest_group = enemy_group
			move_group_to_position(player_group, closest_group.global_position)
			await player_group.group_stoped_moving
			if Global.game.is_in_combat:
				await Global.game.combat_ended
			Global.main_camera.focus_target = null
	Global.game.skip_turn()

func move_group_to_position(group: SelectableGroup, position: Vector2):
	var group_nodes = get_tree().get_nodes_in_group(group.name)
	get_tree().call_group(group.name, "hint_group_size", group_nodes.size())
	get_tree().call_group(group.name, "go_to_position", position)
