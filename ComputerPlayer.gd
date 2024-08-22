extends Node


func _on_game_player_changed(player: Player):
	var player_weak = weakref(player)
	if player_weak.get_ref().user_controlled:
		return
		
	print("CPU player %s" % player_weak.get_ref().name)
	var groups = Global.groups.get_children()
	var player_groups = groups.filter(func(group): return player_weak.get_ref().race == group.race)
	for player_group: SelectableGroup in player_groups:
		groups = Global.groups.get_children()
		var enemy_groups = groups.filter(func(group): return player_weak.get_ref() != null and player_weak.get_ref().race != group.race)
		if enemy_groups.size() > 0:
			player_group.emit_wants_to_be_selected()
			Global.main_camera.focus_target = weakref(player_group)
			await get_tree().create_timer(1.5).timeout
			print("will move group %s" % player_group.name)
			var closest_distance = 99999
			var closest_group: WeakRef = weakref(enemy_groups[0])
			for enemy_group: SelectableGroup in enemy_groups:
				var groups_distance = player_group.global_position.distance_to(enemy_group.global_position) - (player_group.radius + enemy_group.radius)
				if not enemy_group or is_instance_valid(enemy_group) == false or enemy_group.is_queued_for_deletion() or not player_group or is_instance_valid(player_group) == false or player_group.is_queued_for_deletion() or groups_distance <= 0:
					continue
				if player_group.global_position.distance_to(enemy_group.global_position) < closest_distance:
					closest_distance = player_group.global_position.distance_to(enemy_group.global_position)
					closest_group = weakref(enemy_group)
			print("to group %s" % closest_group.get_ref().name)
			move_group_to_position(player_group, closest_group.get_ref().global_position)
			await player_group.group_stoped_moving
			if Global.game.is_in_combat:
				print("wait for end of combat")
				await Global.game.combat_ended
			print("group stopped moving")
			Global.main_camera.focus_target = null
	Global.game.skip_turn()

func move_group_to_position(group: SelectableGroup, position: Vector2):
	var group_nodes = get_tree().get_nodes_in_group(group.name)
	get_tree().call_group(group.name, "hint_group_size", group_nodes.size())
	get_tree().call_group(group.name, "go_to_position", position)
