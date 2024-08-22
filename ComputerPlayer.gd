extends Node


func _on_game_player_changed(player: Player):
	var player_weak = weakref(player)
	if player.user_controlled:
		return
		
	print_debug("CPU player %s" % player_weak.name)
	var groups = Global.groups.get_children()
	var player_groups = groups.filter(func(group): return player_weak.race == group.race)
	for player_group: SelectableGroup in player_groups:
		var enemy_groups = groups.filter(func(group): return player_weak.race != group.race)
		if enemy_groups.size() > 0:
			player_group.emit_wants_to_be_selected()
			Global.main_camera.focus_target = player_group
			await get_tree().create_timer(1.5).timeout
			print_debug("will move group %s" % player_group.name)
			var closest_distance = 99999
			var closest_group = weakref(enemy_groups[0])
			for enemy_group: SelectableGroup in enemy_groups:
				var groups_distance = player_group.global_position.distance_to(enemy_group.global_position) - (player_group.radius + enemy_group.radius)
				if is_instance_valid(enemy_group) == false or enemy_group.is_queued_for_deletion() or is_instance_valid(player_group) == false or player_group.is_queued_for_deletion() or groups_distance <= 0:
					continue
				if player_group.global_position.distance_to(enemy_group.global_position) < closest_distance:
					closest_distance = player_group.global_position.distance_to(enemy_group.global_position)
					closest_group = enemy_group
			print_debug("to group %s" % closest_group.name)
			move_group_to_position(player_group, closest_group.global_position)
			await player_group.group_stoped_moving
			if Global.game.is_in_combat:
				print_debug("wait for end of combat")
				await Global.game.combat_ended
			print_debug("group stopped moving")
			Global.main_camera.focus_target = null
	Global.game.skip_turn()

func move_group_to_position(group: SelectableGroup, position: Vector2):
	var group_nodes = get_tree().get_nodes_in_group(group.name)
	get_tree().call_group(group.name, "hint_group_size", group_nodes.size())
	get_tree().call_group(group.name, "go_to_position", position)
