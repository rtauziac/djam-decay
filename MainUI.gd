extends Control
class_name MainUI


func _ready():
	Global.main_ui = self
	$TitleLabel.visible = false


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
	for process_tween in get_tree().get_processed_tweens():
		if process_tween.get_meta("tween") == "header":
			process_tween.kill()
	var tween = get_tree().create_tween()
	tween.set_meta("tween", "header")
	$HeaderLabel.text = header
	tween.tween_callback(func(): $HeaderLabel.visible = true)
	tween.tween_property($HeaderLabel, "modulate", Color.WHITE, 0.4)


func hide_header():
	for process_tween in get_tree().get_processed_tweens():
		if process_tween.get_meta("tween") == "header":
			process_tween.kill()
	var tween = get_tree().create_tween()
	tween.set_meta("tween", "header")
	tween.tween_property($HeaderLabel, "modulate", Color.TRANSPARENT, 0.4)
	tween.tween_callback(func(): $HeaderLabel.visible = false)

