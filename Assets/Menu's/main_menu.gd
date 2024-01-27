extends Control

@export var first_level : PackedScene = preload("res://Assets/Levels/Level.tscn")

func _on_start_button_down():
	get_tree().change_scene_to_packed(first_level)

func _on_options_button_down():
	print("options menu")

func _on_exit_button_down():
	get_tree().quit()
