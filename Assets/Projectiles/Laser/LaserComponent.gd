extends Node3D

@export var laser_range : float = 40.0
@export var damage_per_second : float = 200.0

@onready var raycast : RayCast3D = $RayCast3D
@onready var laser : MeshInstance3D = $LaserMesh
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	
	raycast.target_position = -player.campivot.transform.basis.z * laser_range
	
	if Input.is_action_pressed("cast_spell") && player.current_spell == player.SpellBook.LSD:
		
		laser.visible = true
		
		if !raycast.is_colliding():
			return
		
		var ray_hit_pos = raycast.get_collision_point()
		
		if raycast.is_colliding():
			laser.mesh.height = global_position.distance_to(ray_hit_pos) 
		else:
			laser.mesh.height = laser_range
		laser.look_at(ray_hit_pos)
		laser.rotation_degrees.x += 90.0
		
		if raycast.get_collider().is_in_group("Enemy"):
			var enemy = raycast.get_collider()
			
			print(enemy)
			
			enemy.take_damage(damage_per_second * delta)
	else:
		laser.visible = false
