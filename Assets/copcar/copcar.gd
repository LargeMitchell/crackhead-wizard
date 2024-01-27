class_name Copcar extends CharacterBody3D

@onready var node3D = $Node3D
@onready var origin: Marker3D = $Origin
@onready var stop_point: Marker3D = $StopPoint
@onready var destination: Marker3D = $Destination

@export var move_speed: float = 8.0
@export var state: int = copcar_state.WAITING

@onready var enemy : PackedScene = preload("res://assets/enemies/Knight/enemy.tscn")

enum copcar_state
{
	WAITING,
	MOVING,
	STOPPED,
	SPAWNED,
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
			spawn_enemies(3)
		copcar_state.LEAVING:
			drive_to_marker(delta, destination)
		_:
			pass

func drive_to_marker(delta, marker: Marker3D):
	node3D.global_position  = node3D.global_position.move_toward(marker.global_position, move_speed * delta)
	if node3D.global_position == marker.global_position:
		state = copcar_state.STOPPED
		return

func spawn_enemies(count: int):
	for i in range(count):
		var enemy = enemy.instantiate()
		owner.add_child(enemy)
		enemy.global_position = global_position + Vector3(0, 0.5, 0)
	state = copcar_state.SPAWNED


