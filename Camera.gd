extends Camera2D

var moving = false
var has_moved = false


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
	
	if event is InputEventMouseMotion:
		var event_mouse_motion: InputEventMouseMotion = event
		
		if moving:
			translate(-event_mouse_motion.relative)
			has_moved = true
			get_tree().root.get_viewport().set_input_as_handled()
