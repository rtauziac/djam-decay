extends RigidBody2D
class_name Unit

enum Race {
	Rat,
	Cat,
	Dog
}


@export var race: Race


func _physics_process(delta):
	if $NavigationAgent2D.is_target_reachable():
		if not $NavigationAgent2D.is_target_reached():
			apply_central_force(($NavigationAgent2D.get_next_path_position() - global_position).normalized() * 600)
	if $NavigationAgent2D.is_target_reached():
		if global_position.distance_to($NavigationAgent2D.target_position) > $NavigationAgent2D.target_desired_distance * 2:
			$NavigationAgent2D.target_position = $NavigationAgent2D.target_position


func go_to_position(position: Vector2):
	$NavigationAgent2D.target_position = position
