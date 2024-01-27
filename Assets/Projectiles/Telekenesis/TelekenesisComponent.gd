extends Node3D

@export var telekenesis_range : float = 20.0
@export var telekenesis_force : float = 100.0

var grabbed_enemy : Node3D
var old_parent : Node3D
var is_grabbing : bool = false

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var raycast : ShapeCast3D = $ShapeCast3D

func _physics_process(delta):
	
	raycast.target_position = -player.campivot.transform.basis.z * telekenesis_range
	
	if Input.is_action_just_pressed("cast_spell") && player.current_spell == player.SpellBook.PCP:
		if !is_grabbing:
			if !raycast.is_colliding():
				return
			if raycast.get_collider(0).is_in_group("Enemy"):
				raycast_hit()
				print("enemy grabbed")
				
	
	if Input.is_action_just_released("cast_spell"):
		print("launch enemy")
		if grabbed_enemy:
			grabbed_enemy.reparent(old_parent)
			launch_enemy()

func raycast_hit():
	grabbed_enemy = raycast.get_collider(0)
	is_grabbing = true
	
	old_parent = grabbed_enemy.get_parent()
	grabbed_enemy.reparent(player.campivot)
	grabbed_enemy.grabbed = true
	grabbed_enemy.velocity = Vector3.ZERO

func launch_enemy():
	grabbed_enemy.velocity = -player.campivot.transform.basis.z * telekenesis_force
	grabbed_enemy = null
	is_grabbing = false
