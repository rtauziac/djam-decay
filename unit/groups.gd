extends Node2D


func _ready():
	call_deferred("make_initial_groups")


func make_initial_groups():
	var unit_scene = preload("res://unit/unit.tscn")
	for i_race in 3:
		for i_group in 2: # 2 groups for each race
			var group_node = Node.new()
			add_child(group_node)
			for i_unit in 4: 
				var unit = unit_scene.instantiate()
				unit.add_to_group(group_node.name)
				unit.add_to_group(&"unit")
				get_parent().add_child(unit)
