class_name Enemy extends CharacterBody3D

@onready var animated_sprite_3d = $AnimatedSprite3D

@export var health: float = 100.0
@export var move_speed: float = 1.5
@export var attack_damage: float = 10.0
@export var attack_range: float = 10.0
@export var notice_range: float = 20.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var state_timer: float = 0.0
@export var attack_cd: float = 1.0

enum enemy_state 
{
	CHASING,
	SHOOTING,
	IDLE
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

	match state:
		enemy_state.IDLE:

			if global_position.distance_to(player.global_position) <= notice_range:
				set_state(enemy_state.CHASING)

		enemy_state.CHASING:
			state_timer += delta

			if state_timer >= attack_cd || global_position.distance_to(player.global_position) <= attack_range:
				attack_player()
				set_state(enemy_state.SHOOTING)
				$AnimatedSprite3D.play("Shoot")

		enemy_state.SHOOTING:

			if $AnimatedSprite3D.frame >= 3: # hard coded to make him only shoot once
				set_state(enemy_state.CHASING)
				$AnimatedSprite3D.play("Run")


func _physics_process(delta):
	if health <= 0:
		return

	if player == null:
		return

	if state != enemy_state.CHASING:
		return

	var dir = player.global_position - global_position
	dir.y = 0.0
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

func take_damage(damage_amount:float):
	health -= damage_amount
	if health <= 0:
		print("dead knight!")
		animated_sprite_3d.play("Death")
		$DeathSound.play()
		$CollisionShape3D.disabled = true


