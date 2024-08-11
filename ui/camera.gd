extends Camera2D
class_name GameCamera

var moving = false
var has_moved = false
var controllable = true
var focus_target = null #Vector2


func _ready():
	Global.main_camera = self


func _process(delta):
	if focus_target != null:
		global_position = lerp(global_position, focus_target, min(1, delta * 4))


func _unhandled_input(event):
	if not controllable or focus_target != null:
		return
	
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
		
		if moving:
			translate(-event_mouse_motion.relative / zoom)
			has_moved = true
			get_tree().root.get_viewport().set_input_as_handled()
