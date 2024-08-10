extends RigidBody2D
class_name Unit

enum Race {
	Rat,
	Cat,
	Dog
}


@export var race: Race
var walk_stamina: float
var group_size = 1
var wake_target_factor = 1

var previous_physics_position: Vector2


func _ready():
	previous_physics_position = global_position


func _physics_process(delta):
	if walk_stamina > 0:
		if $NavigationAgent2D.is_target_reachable():
			if not $NavigationAgent2D.is_target_reached():
				apply_central_force(($NavigationAgent2D.get_next_path_position() - global_position).normalized() * 600)
				var move_vector = previous_physics_position - global_position
				walk_stamina -= pow(move_vector.length() * 0.7, 1.5)
	if $NavigationAgent2D.is_target_reached():
		if global_position.distance_to($NavigationAgent2D.target_position) > $NavigationAgent2D.target_desired_distance * wake_target_factor:
			$NavigationAgent2D.target_position = $NavigationAgent2D.target_position
	previous_physics_position = global_position


func go_to_position(position: Vector2):
	$NavigationAgent2D.target_position = position


# tells the size of his group so it can adapt pathfinding
func hint_group_size(size: int):
	group_size = size
	wake_target_factor = harmonic_function(size) * 1.5
	$NavigationAgent2D.target_desired_distance = 50 * harmonic_function(size) * 2


func set_walk_stamina(stamina: float):
	walk_stamina = stamina


func harmonic_function(value: int) -> float:
	if value <= 0:
		return 0
	var sum = 0
	for i in value:
		sum += 1 / (i + 1)
	return sum
