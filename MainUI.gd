extends Control
class_name MainUI


func _ready():
	Global.main_ui = self
	$TitleLabel.visible = false
	$TitleLabel.modulate = Color.TRANSPARENT


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

