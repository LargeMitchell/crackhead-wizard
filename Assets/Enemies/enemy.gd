class_name Enemy extends CharacterBody3D

@onready var animated_sprite_3d = $AnimatedSprite3D

@export var health: int = 100
@export var move_speed: int = 100
@export var attack_damage: int = 10
@export var attack_range: int = 10

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if health == 0:
		return
	if player == null:
		return
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()

	velocity = dir * move_speed
	move_and_slide()

func attack_player():
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > attack_range:
		return

	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		player.take_damage(attack_damage)
		
func take_damage(damage_amount:int):
	health -= damage_amount
	if health <= 0:
		animated_sprite_3d.play("Death")
		$DeathSound.play()
		$CollisionShape3D.disabled = true


