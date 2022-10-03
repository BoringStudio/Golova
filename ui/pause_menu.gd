extends Control

signal game_resumed;

func _ready():
	pass


func _on_Resume_pressed():
	get_tree().paused = false
	emit_signal("game_resumed")


func _on_Exit_pressed():
	get_tree().quit()


func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		get_tree().set_input_as_handled()
		emit_signal("game_resumed")
