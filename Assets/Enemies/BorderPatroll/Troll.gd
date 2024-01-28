extends CharacterBody3D

@onready var animated_sprite_3d = $AnimatedSprite3D

@export var health: float = 100.0
@export var move_speed: float = 1.5
@export var attack_damage: float = 10.0
@export var attack_range: float = 10.0
@export var notice_range: float = 20.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var bullet : PackedScene = preload("res://Assets/Projectiles/Bullet.tscn")

@onready var coke : PackedScene = preload("res://Assets/Pick-ups/Coke.tscn")
@onready var lsd : PackedScene = preload("res://Assets/Pick-ups/LSD.tscn")
@onready var meth : PackedScene = preload("res://Assets/Pick-ups/Meth.tscn")

var drug_offset: Array = [Vector3(1, 0, 0), Vector3(0, 0, 0), Vector3(-1, 0, 0)]

var dead : bool = false

var state_timer: float = 0.0
var grabbed : bool = false
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
	if !grabbed:
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
	if !grabbed:
		var p = bullet.instantiate()
		add_child(p)
		p.global_transform.origin = global_transform.origin + Vector3.UP
		p.direction = Vector3((player.global_position + (-Vector3.UP)) - global_position).normalized()

func take_damage(damage_amount:float):
	health -= damage_amount
	
	if dead == false:
		if health <= 0:
			animated_sprite_3d.play("Death")
			$DeathSound.play()
			$CollisionShape3D.disabled = true
			player.killed_enemy = true
			var c = coke.instantiate()
			var m = meth.instantiate()
			var l = lsd.instantiate()
			var dead_times: int = 0
			add_child(c)
			add_child(m)
			add_child(l)
			drug_offset.shuffle()
			c.global_position = global_position + drug_offset[0]
			m.global_position = global_position + drug_offset[1]
			l.global_position = global_position + drug_offset[2]
			dead_times += 1
			if dead_times > 3:
				dead = true
		
