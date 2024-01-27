extends Node3D

var lifetime: float = 0.0

@export var range: float = 250.0
@export var duration_between_spawns: float = 5.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var enemy : PackedScene = preload("res://Assets/Enemies/Knight/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	lifetime += delta
	
	if  lifetime >= duration_between_spawns && player.global_position.distance_to (global_position) <= range:
		
		lifetime = 0.0
		
		var e = enemy.instantiate()
		owner.add_child(e)
		
		
