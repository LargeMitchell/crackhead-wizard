class_name Projectile extends Area3D

@export var projectile_speed : float = 10.0
@export var lifetime : float = 2.0

var direction : Vector3
var timer : float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += direction * projectile_speed * delta
	
	# bullet timer
	timer += delta
	if timer >= lifetime:
		queue_free()

func _on_body_entered(body):
	if body is Enemy:
		print("enemy hit")
		queue_free()
