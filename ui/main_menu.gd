extends Control

signal game_started;

func _ready():
	pass


func _on_Start_pressed():
	emit_signal("game_started")


func _on_Exit_pressed():
	get_tree().quit()
