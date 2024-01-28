extends Area3D

@export var damage : float = 200.0

@onready var sprite : AnimatedSprite3D = $AnimatedSprite3D
@onready var collision : BoxShape3D = $CollisionShape3D.shape
@onready var explosion : PackedScene = preload("res://Assets/VFX/Explosion/Explosion.tscn")

@onready var charge_value: float = 0.0
@onready var direction: Vector3 = Vector3(0.0, 0.0, 0.0)

func set_charge_scale():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("default")

func _on_body_entered(body):	
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		var explodeanim = explosion.instantiate()
		get_parent().add_child(explodeanim)
		explodeanim.global_position = global_position

func _on_animated_sprite_3d_animation_finished():
	queue_free()
