extends Line2D

enum LineType {
	Selection,
	CombatHighlight
}


@export var radius = 100 : get = get_radius, set = set_radius
@export var line_type: LineType = LineType.Selection
var rand_line = RandomNumberGenerator.new()


func get_selected():
	return 

func _ready():
	pass


func get_radius():
	return radius


func set_radius(new_val):
	radius = new_val
	update_line()


func update_line():
	rand_line.seed = get_instance_id()
	var segments = points.size()
	for segment in points.size():
		match line_type:
			LineType.Selection:
				points[segment].x = cos(segment * PI / segments * 2) * radius
				points[segment].y = sin(segment * PI / segments * 2) * radius
			LineType.CombatHighlight:
				var alter_size = rand_line.randf() * 0.1 + 0.95
				points[segment].x = cos(segment * PI / segments * 2) * radius * alter_size
				points[segment].y = sin(segment * PI / segments * 2) * radius * alter_size
