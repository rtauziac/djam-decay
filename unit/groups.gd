extends Node2D


func _ready():
	set_process_inputs(false)
	call_deferred("make_initial_groups")


func make_initial_groups():
	var rand_start_angle = randf() * PI * 2
	var races: Array = [preload("res://unit/rat.tscn"), preload("res://unit/cat.tscn"), preload("res://unit/dog.tscn")]
	var race_names: Array = [Unit.Race.keys()[Unit.Race.Rat], Unit.Race.keys()[Unit.Race.Cat], Unit.Race.keys()[Unit.Race.Dog]]
	for i_race in races.size():
		var group_node: SelectableGroup = preload("res://unit/group.tscn").instantiate()
		group_node.global_position = Vector2.UP.rotated(rand_start_angle + i_race * PI * 0.666) * 250
		group_node.name = race_names[i_race]
		group_node.wants_to_be_selected.connect(handle_group_selection)
		group_node.engage_combat.connect(Global.game.combat_groups)
		add_child(group_node)
		for i_unit in 12:
			var unit: Unit = races[i_race].instantiate()
			unit.global_position = group_node.global_position + Vector2.RIGHT.rotated(randf() * PI * 2) * 20
			unit.add_to_group(group_node.name)
			unit.add_to_group(&"unit")
			get_parent().add_child(unit)
			unit.go_to_position(group_node.global_position)


func _physics_process(delta):
	for group: SelectableGroup in get_children():
		var group_nodes := get_tree().get_nodes_in_group(group.name)
		if group_nodes == null or group_nodes.size() == 0:
			continue
		
		var bounds_new := Rect2(group_nodes[0].global_position, Vector2.ZERO)
		var longest_distance = 0
		var total_stamina = group_nodes.size() * Global.game.stamina_start_amount
		var real_stamina = 0
		for unit: Unit in group_nodes:
			real_stamina += unit.walk_stamina
			if bounds_new.has_point(unit.global_position) == false:
				bounds_new = bounds_new.expand(unit.global_position)
			var unit_distance = group.global_position.distance_to(unit.global_position) + (20)
			if unit_distance > longest_distance:
				longest_distance = unit_distance
		group.stamina = real_stamina / total_stamina
		group.global_position = bounds_new.get_center()
		#var selectable_group := group.find_child("CollisionShape2D") as SelectableGroup
		group.radius = longest_distance


func _input(event):
	if event is InputEventMouseButton:
		var eventMouseButton := event as InputEventMouseButton
		if eventMouseButton.pressed:
			if eventMouseButton.button_index == MOUSE_BUTTON_RIGHT:
				var groups = get_children()
				var selected_groups := groups.filter(func (group: SelectableGroup): return group.selected)
				if selected_groups.size() > 0:
					for selected_group: SelectableGroup in selected_groups:
						var group_nodes = get_tree().get_nodes_in_group(selected_group.name)
						get_tree().call_group(selected_group.name, "hint_group_size", group_nodes.size())
						get_tree().call_group(selected_group.name, "go_to_position", get_global_mouse_position())
					get_tree().root.get_viewport().set_input_as_handled()


func _on_game_player_changed(player: Player):
	set_process_inputs(player.user_controlled)
	for group in get_children():
		if group.name == Unit.Race.keys()[player.race]:
			for node: Unit in get_tree().get_nodes_in_group(group.name):
				node.set_walk_stamina(Global.game.stamina_start_amount)


func set_process_inputs(active: bool):
	set_process_input(active)
	set_process_unhandled_input(active)
	for group in get_children():
		group.set_process_input(active)
		group.set_process_unhandled_input(active)


func handle_group_selection(group_wants: SelectableGroup):
	for group: SelectableGroup in get_children():
		group.selected = true if group == group_wants else false
