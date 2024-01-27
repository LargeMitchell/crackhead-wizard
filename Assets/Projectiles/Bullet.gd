class_name Bullet extends Area3D

var projectile_speed : float = 15.0
var lifetime : float = 5.0
var damage : float = 10.0
var direction : Vector3 = Vector3.ZERO
var timer : float = 0.0

func _physics_process(delta):
	
	position += direction * projectile_speed * delta
	
	# bullet timer
	timer += delta
	if timer >= lifetime:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
		queue_free()
