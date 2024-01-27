class_name Copcar extends CharacterBody3D

@onready var node3D = $Node3D
@onready var origin: Marker3D = $Origin
@onready var stop_point: Marker3D = $StopPoint
@onready var destination: Marker3D = $Destination

@export var move_speed: float = 8.0
@export var state: int = copcar_state.WAITING
@export var enemies_to_spawn: int = 3
var spawned_enemies: int = 0
# Want them to spawn around the cop car in a somewhat belivable way
var enemy_offset: Array = [Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0)]

@onready var enemy : PackedScene = preload("res://assets/enemies/Knight/enemy.tscn")
@onready var timer : Timer = $Timer

enum copcar_state
{
	WAITING,
	MOVING,
	STOPPED,
	LEAVING
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		copcar_state.WAITING:
			pass
		copcar_state.MOVING:
			drive_to_marker(delta, stop_point)
		copcar_state.STOPPED:
			state = copcar_state.WAITING
			spawn_enemies()
		copcar_state.LEAVING:
			drive_to_marker(delta, destination)
		_:
			pass

func drive_to_marker(delta, marker: Marker3D):
	node3D.global_position  = node3D.global_position.move_toward(marker.global_position, move_speed * delta)
	if node3D.global_position == marker.global_position:
		state = copcar_state.STOPPED
		return

func spawn_enemies():
	timer.start()

func _on_timer_timeout():
	if spawned_enemies < enemies_to_spawn:
		spawned_enemies += 1
		spawn_enemy()
	else:
		timer.stop()
		state = copcar_state.LEAVING

func spawn_enemy():
	var e = enemy.instantiate()
	owner.add_child(e)
	enemy_offset.shuffle()
	e.global_position = global_position + enemy_offset[0]
