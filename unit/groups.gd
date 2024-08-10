extends Node2D


func _ready():
	call_deferred("make_initial_groups")


func make_initial_groups():
	var rand_start_angle = randf() * PI * 2
	var races: Array = [preload("res://unit/rat.tscn"), preload("res://unit/cat.tscn"), preload("res://unit/dog.tscn")]
	for i_race in races.size():
		var group_node = preload("res://unit/group.tscn").instantiate()
		group_node.global_position = Vector2.UP.rotated(rand_start_angle + i_race * PI * 0.666) * 100
		add_child(group_node)
		for i_unit in 8:
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
		for node: RigidBody2D in group_nodes:
			#node.linear_velocity = (group.global_position - node.global_position).normalized() * 10
			if bounds_new.has_point(node.global_position) == false:
				bounds_new = bounds_new.expand(node.global_position)
			var node_distance = group.global_position.distance_to(node.global_position) + (20)
			if node_distance > longest_distance:
				longest_distance = node_distance
		
		group.global_position = bounds_new.get_center()
		var selectable_group := group.find_child("CollisionShape2D") as SelectableGroup
		group.radius = longest_distance


func _input(event):
	if event is InputEventMouseButton:
		var eventMouseButton := event as InputEventMouseButton
		if eventMouseButton.pressed:
			if eventMouseButton.button_index == MOUSE_BUTTON_RIGHT:
				#for group: SelectableGroup in get_children():
				var group_units = get_children()
				var selected_groups := group_units.filter(func (group: SelectableGroup): return group.selected)
				if selected_groups.size() > 0:
					for selected_group: SelectableGroup in selected_groups:
						#get_global_mouse_position()
						get_tree().call_group(selected_group.name, "go_to_position", get_global_mouse_position())
					get_tree().root.get_viewport().set_input_as_handled()
