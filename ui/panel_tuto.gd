extends Panel

var content_titles = ["instructions", "controls", "turn", "fight", "interface"]
var contents = Array()
var content_index = 0


func _ready():
	for title in content_titles:
		var content = FileAccess.get_file_as_string("res://ui/tuto/%s.txt" % title)
		contents.append(content)
	update_current_page()


func update_current_page():
	$Control/LabelHeader.text = content_titles[content_index]
	$Control/VBoxContainer/RichTextLabel.text = contents[content_index]
	$Control/VBoxContainer/HBoxContainer/Left.disabled = content_index <= 0
	$Control/VBoxContainer/HBoxContainer/Right.disabled = content_index >= content_titles.size() - 1


func next_page():
	content_index += 1
	update_current_page()


func previous_page():
	content_index -= 1
	update_current_page()

