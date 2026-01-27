extends Control

func _on_button_pressed():
	GameManager.reset_run()
	# Make sure to unpause if you paused on death
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_1.tscn")
