extends Node2D


func _ready():
	Global.groups = self
	set_process_inputs(false)
	call_deferred("make_initial_groups")


func make_initial_groups():
	var rand_start_angle = randf() * PI * 2
	var races: Array = [preload("res://unit/rat.tscn"), preload("res://unit/cat.tscn"), preload("res://unit/dog.tscn")]
	var race_names: Array = [Unit.Race.keys()[Unit.Race.Rat], Unit.Race.keys()[Unit.Race.Cat], Unit.Race.keys()[Unit.Race.Dog]]
	var groups_by_player = 3
	for i_race in races.size() * groups_by_player:
		var group: SelectableGroup = preload("res://unit/group.tscn").instantiate()
		group.race = Unit.Race.values()[i_race % 3]
		var group_angle = rand_start_angle + (PI * 2 / (races.size() * groups_by_player)) * i_race
		print("group_angle %f" % group_angle)
		group.global_position = Vector2.RIGHT.rotated(group_angle) * randf_range(800, 2600)
		group.name = race_names[i_race % 3]
		group.wants_to_be_selected.connect(handle_group_selection)
		group.engage_combat.connect(Global.game.combat_groups)
		Global.game.player_changed.connect(func(): for group_connect: SelectableGroup in get_children(): group_connect.selected = false)
		add_child(group)
		for i_unit in randi_range(4, 8):
			var unit: Unit = races[i_race % 3].instantiate()
			unit.global_position = group.global_position + Vector2.RIGHT.rotated(randf() * PI * 2) * 20
			unit.add_to_group(group.name)
			unit.add_to_group(&"unit")
			get_parent().add_child(unit)
			unit.go_to_position(group.global_position)


func _physics_process(delta):
	for group: SelectableGroup in get_children():
		var groups := get_tree().get_nodes_in_group(group.name)
		if groups == null or groups.size() == 0:
			continue
		
		var bounds_new := Rect2(groups[0].global_position, Vector2.ZERO)
		var longest_distance = 0
		var total_stamina = groups.size() * Global.game.stamina_start_amount
		var real_stamina = 0
		for unit: Unit in groups:
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
	var player_groups = get_children().filter(func(group): return group.race == player.race)
	if player_groups.size() == 0:
		return
	
	for player_group in player_groups:
		var groups = get_tree().get_nodes_in_group(player_group.name)
		for node: Unit in groups:
			node.set_walk_stamina(Global.game.stamina_start_amount)
	var first_group: SelectableGroup = player_groups[0]
	first_group.emit_wants_to_be_selected()
	Global.main_camera.move_to_position(first_group.global_position)


func set_process_inputs(active: bool):
	set_process_input(active)
	set_process_unhandled_input(active)
	for group in get_children():
		group.set_process_input(active)
		group.set_process_unhandled_input(active)


func handle_group_selection(group_wants: SelectableGroup):
	for group: SelectableGroup in get_children():
		group.selected = true if group == group_wants else false
