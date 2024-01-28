extends CharacterBody3D

@export var health: int = 100
@export var move_speed: float = 5.5
@export var attack_damage: int = 10
@export var attack_range: int = 5
@export var notice_range: int = 20

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var bullet : PackedScene = preload("res://Assets/Projectiles/Bullet.tscn")

var state_timer: float = 0.0
@export var attack_cd: float = 2.0

var chase_pos: Vector3 = Vector3(0.0, 0.0, 0.0)

var rand_height: float = 0.0
var rand_dist: float = 10.0
var rand_rot_offset: float = 90.0
var shot_time: float = 0.05
var shot_timer: float = 0.0
var rng = RandomNumberGenerator.new()

func reroll_point():
	rand_height = rng.randf_range(3.0, 5.0)
	rand_dist = rng.randf_range(7.5, 12.5)
	rand_rot_offset = rng.randf() * PI * 2.0
	
func _enter_tree():
	reroll_point()

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

var charge_hit_player = false

func _process(delta):
	if health <= 0:
		global_position += Vector3(0.0, -delta * 6.0, 0.0)
		global_rotate(Vector3(0.0, 1.0, 0.0), delta)
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
				
				if randi_range(0, 1) == 0:
					set_state(enemy_state.CHARGING)
					chase_pos = player.global_position
					charge_hit_player = false
				else:
					set_state(enemy_state.SHOOTING)
					var nx = sin(PI * 2.0 + rand_rot_offset)
					var nz = cos(PI * 2.0 + rand_rot_offset)
					chase_pos = player.global_position + Vector3(nx * rand_dist, rand_height, nz * rand_dist)
					
					reroll_point()

		enemy_state.CHARGING:
			state_timer += delta
			
			if state_timer >= 1.0:	
				set_state(enemy_state.CHASING)
				
		enemy_state.SHOOTING:
			state_timer += delta
			shot_timer += delta
			
			if shot_timer >= shot_time:
				
				shot_timer -= shot_time
				
				var p = bullet.instantiate()
				add_child(p)
				p.global_transform.origin = global_transform.origin + Vector3.UP
				p.direction = Vector3((player.global_position + (-Vector3.UP)) - global_position) + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
				p.direction = p.direction.normalized()
							
			$".".look_at(player.global_position, Vector3.UP)
			
			if state_timer >= 2.5:
				set_state(enemy_state.CHASING)
				

func _physics_process(delta):
	if health <= 0:
		return
		
	if player == null:
		return
		
	if state == enemy_state.CHARGING && !charge_hit_player:
		
		if global_position.distance_to(player.global_position) <= 5.0:
			player.take_damage(attack_damage)
			charge_hit_player = true
	
	var dir = chase_pos - global_position
	dir = dir.normalized()

	velocity = dir * move_speed
	move_and_slide()
		
		
func take_damage(damage_amount:int):
	health -= damage_amount
	if health <= 0:
		$DeathSound.play()
		$CollisionShape3D.disabled = true
