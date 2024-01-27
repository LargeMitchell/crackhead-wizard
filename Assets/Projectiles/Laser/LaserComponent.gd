extends Node3D

@export var laser_range : float = 20.0

@onready var raycast : RayCast3D = $RayCast3D
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	
	raycast.target_position = -player.campivot.transform.basis.z * laser_range
	
	if Input.is_action_pressed("cast_spell") && player.current_spell == player.SpellBook.LSD:
		pass
