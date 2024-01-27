extends CharacterBody3D

@export var health: int = 100
@export var move_speed: float = 5.5
@export var attack_damage: int = 10
@export var attack_range: int = 10
@export var notice_range: int = 20

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var state_timer: float = 0.0
@export var attack_cd: float = 2.0

var chase_pos: Vector3 = Vector3(0.0, 0.0, 0.0)

var rand_height: float = 0.0
var rand_dist: float = 10.0
var rand_rot_offset: float = 90.0
var rot_time: float = 0.0
var rng = RandomNumberGenerator.new()

func _enter_tree():
	rand_height = rng.randf_range(3.0, 5.0)
	rand_dist = rng.randf_range(7.5, 12.5)
	rand_rot_offset = rng.randf() * PI * 2.0

enum enemy_state 
{
	CHASING,
	SHOOTING,
	IDLE,
	CHARGING
}
var state: enemy_state = enemy_state.IDLE

func set_state(new_state: enemy_state):
	state = new_state
	state_timer = 0.0

func _process(delta):
	if health <= 0:
		return
		
	if player == null:
		return
		
	$WyvernBody/WyvernWings.rotation += Vector3(0.0, delta * 100.0, 0.0)
	
	match state:
		enemy_state.IDLE:
			
			$".".look_at(player.global_position, Vector3.UP)
			
			chase_pos = player.global_position + Vector3(0.0, rand_height, 0.0)
			
			if global_position.distance_to(player.global_position) <= notice_range:
				set_state(enemy_state.CHASING)
				chase_pos = player.global_position
			
		enemy_state.CHASING:
			
			$".".look_at(player.global_position, Vector3.UP)
			
			state_timer += delta
			
			chase_pos = player.global_position + Vector3(0.0, rand_height, 0.0)
			
			if state_timer >= 1.0:
				set_state(enemy_state.CHARGING)
				chase_pos = player.global_position
			
			#var nx = sin(state_timer * PI * 2.0 + rand_rot_offset)
			#var nz = cos(state_timer * PI * 2.0 + rand_rot_offset)
			
		enemy_state.CHARGING:
			state_timer += delta
			
			if state_timer >= 1.0:	
				enemy_state.CHASING
				
		enemy_state.SHOOTING:
			
			#if $AnimatedSprite3D.frame >= 3: # hard coded to make him only shoot once
				set_state(enemy_state.CHASING)
				
	

func _physics_process(delta):
	if health <= 0:
		return
		
	if player == null:
		return
		
	var dir = chase_pos - global_position
	dir = dir.normalized()

	velocity = dir * move_speed
	move_and_slide()
	

func attack_player():
	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result.is_empty():
		print("ouch!")
		# player.take_damage(attack_damage)
		
func take_damage(damage_amount:int):
	health -= damage_amount
	if health <= 0:
		$DeathSound.play()
		$CollisionShape3D.disabled = true


