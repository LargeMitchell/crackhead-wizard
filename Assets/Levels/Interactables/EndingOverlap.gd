extends Area3D

@export var ending : PackedScene = preload("res://Assets/Menu's/ending.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	
	if body.is_in_group("player"):
		print("I AM ENTERED")
		get_tree().change_scene_to_packed(ending)
		
