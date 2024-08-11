extends Area2D
class_name SelectableGroup

signal wants_to_be_selected(group: SelectableGroup)
signal engage_combat(group_a: SelectableGroup, group_b: SelectableGroup)

@export var selected: bool : get = get_selected, set = set_selected
func get_selected() -> bool:
	return $SelectionLine2D.visible
func set_selected(new_val: bool):
	$SelectionLine2D.visible = new_val
	$GaugeStamina.visible = new_val

var radius: get = get_radius, set = set_radius
func get_radius() -> float:
	return ($CollisionShape2D.shape as CircleShape2D).radius
func set_radius(new_val: float):
	($CollisionShape2D.shape as CircleShape2D).radius = new_val
	$SelectionLine2D.set("radius", new_val)
	$GaugeStamina.position.y = -(new_val + 20)


var stamina: get = get_stamina, set = set_stamina
func get_stamina():
	return $GaugeStamina.scale.x
func set_stamina(new_val: float):
	$GaugeStamina/GaugeStamina2.scale.x = clamp(new_val, 0, 1)


func _on_input_event(viewport: Viewport, event, shape_idx):
	if Global.game.current_player == null or not Global.game.current_player.user_controlled:
		return
	
	if event is InputEventMouseButton:
		var eventMouseButton := event as InputEventMouseButton
		if not eventMouseButton.pressed:
			var group_nodes = get_tree().get_nodes_in_group(name)
			var units = group_nodes as Array[Unit]
			if Global.game.current_player.race == units[0].race:
				#set_deferred("selected", true)
				emit_signal(wants_to_be_selected.get_name(), self)
				viewport.set_input_as_handled()


func _on_area_entered(area: SelectableGroup):
	if area == null:
		return
	
	var self_race: Unit.Race = get_tree().get_nodes_in_group(name)[0].race
	if self_race == Global.game.current_player.race:
		#print("%s wants to fight %s" % [name, area.name])
		emit_signal(engage_combat.get_name(), self, area)
