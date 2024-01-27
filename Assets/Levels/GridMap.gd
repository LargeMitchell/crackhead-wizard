@tool
extends GridMap


# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		mesh_library=load("res://Assets/Levels/ModularKit/tileset.tres")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
