extends Control

@export var first_level : PackedScene = preload("res://Assets/Levels/Level.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_start_button_down():
	get_tree().change_scene_to_packed(first_level)
