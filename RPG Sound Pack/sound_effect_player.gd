extends Node


func PlayAndForget(sound: AudioStream):
	var player = AudioStreamPlayer.new()
	player.stream = sound
	get_tree().root.add_child(player)
	player.finished.connect(func(): player.queue_free())
	player.play()
