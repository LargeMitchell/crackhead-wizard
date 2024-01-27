class_name Projectile extends Area3D

@export var projectile_speed : float = 10.0
@export var lifetime : float = 2.0

var direction : Vector3
var timer : float = 0.0
var charge_value : float = 0.0

@onready var sprite : Sprite3D = $Sprite3D
@onready var collision : BoxShape3D = $CollisionShape3D.shape

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += direction * projectile_speed * delta
	
	# bullet timer
	timer += delta
	if timer >= lifetime:
		queue_free()

func set_charge_scale():
	var scaling_value : float = remap(clamp(charge_value, 0.0, 1.0), 0.0, 1.0, 1.0, 4.0)
	
	print(scaling_value)
	
	sprite.pixel_size = sprite.pixel_size * scaling_value
	collision.size = collision.size * scaling_value

func _on_body_entered(body):
	if body is Enemy:
		print("enemy hit")
		queue_free()
	elif body is GridMap:
		print("wall hit")
