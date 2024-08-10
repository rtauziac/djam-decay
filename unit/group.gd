extends Area2D
class_name SelectableGroup

@export var selected: bool : get = get_selected, set = set_selected
func get_selected() -> bool:
	return $Line2D.visible
func set_selected(new_val: bool):
	$Line2D.visible = new_val

var radius: get = get_radius, set = set_radius
func get_radius() -> float:
	return ($CollisionShape2D.shape as CircleShape2D).radius
func set_radius(new_val: float):
	($CollisionShape2D.shape as CircleShape2D).radius = new_val
	$Line2D.set("radius", new_val)


func _on_input_event(viewport: Viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var eventMouseButton := event as InputEventMouseButton
		if not eventMouseButton.pressed:
			var group_nodes = get_tree().get_nodes_in_group(name)
			var units = group_nodes as Array[Unit]
			if Global.game.current_player.race == units[0].race or true:
				set_deferred("selected", true)
				viewport.set_input_as_handled()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		var event_mouse_button: InputEventMouseButton = event
		
		if event_mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if not event_mouse_button.pressed:
				set_deferred("selected", false)
