extends CharacterBody3D

@export var health: int = 300
@export var move_speed: float = 5.5
@export var attack_damage: int = 10
@export var attack_range: int = 5
@export var notice_range: int = 20

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var bullet : PackedScene = preload("res://Assets/Projectiles/Bullet.tscn")
@onready var enemy : PackedScene = preload("res://Assets/Enemies/Knight/enemy.tscn")

var state_timer: float = 0.0
@export var attack_cd: float = 2.0

var chase_pos: Vector3 = Vector3(0.0, 0.0, 0.0)

var rand_height: float = 0.0
var rand_dist: float = 10.0
var rand_rot_offset: float = 90.0
var shot_time: float = 0.25
var shot_timer: float = 0.0

var spawn_time: float = 0.5
var spawn_timer: float = 0.0

var rng = RandomNumberGenerator.new()

var grabbed : bool = false

func reroll_point():
	rand_height = rng.randf_range(3.0, 5.0)
	rand_dist = rng.randf_range(7.5, 12.5)
	rand_rot_offset = rng.randf() * PI * 2.0
	
func _enter_tree():
	reroll_point()

enum enemy_state 
{
	SPAWNING,
	SHOOTING,
	IDLE,
	CRASHING
}
var state: enemy_state = enemy_state.CRASHING

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
		
	match state:
		enemy_state.IDLE:
			if global_position.distance_to(player.global_position) <= notice_range:
				set_state(enemy_state.SHOOTING)
		
		enemy_state.SHOOTING:
			shot_timer += delta
			
			if shot_timer >= shot_time:
				
				shot_timer -= shot_time
				
				var p = bullet.instantiate()
				add_child(p)
				p.global_transform.origin = global_transform.origin + Vector3.UP
				p.direction = Vector3((player.global_position + (-Vector3.UP)) - global_position) + Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
				p.direction = p.direction.normalized()
			
			state_timer += delta
			
			chase_pos = player.global_position + Vector3(0.0, rand_height, 0.0)
			
			if state_timer >= 1.6:
				set_state(enemy_state.SPAWNING)

		enemy_state.SPAWNING:
			state_timer += delta
			
			spawn_timer += delta
			
			if spawn_timer >= spawn_time:
				spawn_timer -= spawn_time
				var e = enemy.instantiate()
				owner.add_child(e)
				var offset = (player.global_position - global_position)
				offset.y = 0.0
				offset = offset.normalized() * 4.0
				
				e.global_position = global_position + offset
			if state_timer >= 1.0:	
				if randi_range(0, 1) == 0:
					set_state(enemy_state.SHOOTING)
				else:
					set_state(enemy_state.CRASHING)
		
		enemy_state.CRASHING:
			state_timer += delta
			
			$CSGBox3D.rotate(Vector3(1.0, 0.0, 0.0), -delta * 5.0)
			
			
				

func _physics_process(delta):
	if !grabbed:
		if health <= 0:
			return
		
		if player == null:
			return
		
		
func take_damage(damage_amount:int):
	health -= damage_amount
	if health <= 0:
		$DeathSound.play()
		$CollisionShape3D.disabled = true


