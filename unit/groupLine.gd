extends Line2D

@export var radius = 100 : get = get_radius, set = set_radius


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
	var segments = points.size()
	for segment in points.size():
		points[segment].x = cos(segment * PI / segments * 2) * radius
		points[segment].y = sin(segment * PI / segments * 2) * radius
