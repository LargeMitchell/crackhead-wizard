extends Area3D

@export var damage : float = 200.0

@export var charge_value: float = 0.0

@export var direction: Vector3 = Vector3(0.0, 0.0, 0.0)

@onready var sprite : AnimatedSprite3D = $AnimatedSprite3D
@onready var collision : BoxShape3D = $CollisionShape3D.shape
@onready var explosion : PackedScene = preload("res://Assets/VFX/Explosion/Explosion.tscn")

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("default")
	var ld = -99999.0
	for i in get_tree().get_nodes_in_group("Enemy"):
		var dte = global_position - i.global_position
		dte = dte.normalized()
		var d = dte.dot(player.transform.basis.z)
		
		if global_position.distance_to(i.global_position) <= 500 && d >= ld:
			global_position = i.global_position
			ld = d
			print(d)
	
func set_charge_scale():
	pass

func _on_body_entered(body):	
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		var explodeanim = explosion.instantiate()
		get_parent().add_child(explodeanim)
		explodeanim.global_position = global_position

func _on_animated_sprite_3d_animation_finished():
	queue_free()
