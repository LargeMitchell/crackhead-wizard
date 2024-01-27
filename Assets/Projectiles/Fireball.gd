extends Area3D

@export var projectile_speed : float = 10.0
@export var lifetime : float = 2.0
@export var damage : float = 25.0

var direction : Vector3
var timer : float = 0.0
var charge_value : float = 0.0
var scaling_value : float = 0.0

@onready var sprite : AnimatedSprite3D = $AnimatedSprite3D
@onready var collision : BoxShape3D = $CollisionShape3D.shape
@onready var explosion : PackedScene = preload("res://Assets/VFX/Explosion/Explosion.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += direction * projectile_speed * delta
	
	# bullet timer
	timer += delta
	if timer >= lifetime:
		queue_free()

func set_charge_scale():
	scaling_value = remap(clamp(charge_value, 0.0, 1.0), 0.0, 1.0, 1.0, 4.0)
	
	sprite.pixel_size = sprite.pixel_size * scaling_value
	collision.size = Vector3(0.5,0.5,0.5)
	collision.size.x = collision.size.x * scaling_value
	collision.size.y = collision.size.y * scaling_value

func _on_body_entered(body):
	
	var explodeanim = explosion.instantiate()
	get_parent().add_child(explodeanim)
	explodeanim.global_position = global_position
	explodeanim.scale = explodeanim.scale * scaling_value
	
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
	
	queue_free()
	
	

