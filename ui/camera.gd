extends Camera2D
class_name GameCamera

var moving = false
var has_moved = false
var controllable = true
var focus_target = null #Node2D
func get_focus_target():
	return focus_target
func set_focus_target(new_val):
	focus_target = new_val
	controllable = new_val == null
	moving = new_val == null


func _ready():
	Global.main_camera = self


func move_to_position(position: Vector2):
	controllable = false
	moving = false
	for tween in get_tree().get_processed_tweens():
		if tween.get_meta("tween") == "move_to_position":
			tween.kill()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", position, clamp((global_position - position).length() / 1000, 0.3, 1.2)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.set_meta("tween", "move_to_position")
	tween.tween_callback(func(): controllable = true)


func _process(delta):
	if focus_target != null:
		global_position = lerp(global_position, focus_target.global_position, min(1, delta * 4))


func _unhandled_input(event):
	if event is InputEventMouseButton:
		var event_mouse_button: InputEventMouseButton = event
		
		if event_mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if event_mouse_button.pressed:
				moving = true
				has_moved = false
				get_tree().root.get_viewport().set_input_as_handled()
			else:
				moving = false
				if has_moved:
					get_tree().root.get_viewport().set_input_as_handled()
		elif event_mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if zoom.length() > 0.4:
				zoom *= 0.95
		elif event_mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
			if zoom.length() < 2:
				zoom *= 1.05
	
	if event is InputEventMouseMotion:
		var event_mouse_motion: InputEventMouseMotion = event
		if not controllable or focus_target != null:
			return
		
		if moving:
			translate(-event_mouse_motion.relative / zoom)
			has_moved = true
			get_tree().root.get_viewport().set_input_as_handled()
