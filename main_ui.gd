extends Control
class_name MainUI


func _ready():
	Global.main_ui = self
	$TitleLabel.visible = false
	$TitleLabel.modulate = Color.TRANSPARENT
	await get_tree().process_frame
	Global.game.player_changed.connect(on_player_changed)


func show_title(title: String, callback = null):
	for process_tween in get_tree().get_processed_tweens():
		if process_tween.get_meta("tween") == "title":
			process_tween.kill()
	var tween = get_tree().create_tween()
	tween.set_meta("tween", "title")
	$TitleLabel.text = title
	tween.tween_callback(func(): $TitleLabel.visible = true)
	tween.tween_property($TitleLabel, "modulate", Color.WHITE, 1.2)
	tween.tween_interval(2)
	tween.tween_property($TitleLabel, "modulate", Color.TRANSPARENT, 1.2)
	tween.tween_callback(func(): $TitleLabel.visible = false)
	if callback != null:
		tween.tween_callback(callback)


func show_header(header: String):
	$HeaderLabel.text = header
	$AnimationPlayer.play("header_appear")


func hide_header():
	$AnimationPlayer.play("header_hide")


func _on_button_next_turn_pressed():
	Global.game.skip_turn()


func on_player_changed(player: Player):
	$PlayerTurnControl/ButtonNextTurn.visible = player.user_controlled
	var race_name = Unit.Race.keys()[player.race]
	$PlayerTurnControl/TeamLabel.text = "%s turn" % race_name
	show_title("%s team" % race_name)
	
	for button in $PlayerTurnControl/GroupButtonLayout.get_children():
		button.queue_free()
	if player.user_controlled:
		update_group_buttons()
	

func update_group_buttons():
	for button in $PlayerTurnControl/GroupButtonLayout.get_children():
		button.visible = false
		button.queue_free()
	var player_groups := Global.groups.get_children().filter(func(group): var nodes = get_tree().get_nodes_in_group(group.name); return nodes.size() > 0 and nodes[0].race == Global.game.current_player.race)
	for group: SelectableGroup in player_groups:
		var group_nodes = get_tree().get_nodes_in_group(group.name)
		var button = Button.new()
		button.text = "%d" % group_nodes.size()
		button.pressed.connect(func(): Global.main_camera.move_to_position(group.global_position); group.emit_wants_to_be_selected())
		$PlayerTurnControl/GroupButtonLayout.add_child(button)
