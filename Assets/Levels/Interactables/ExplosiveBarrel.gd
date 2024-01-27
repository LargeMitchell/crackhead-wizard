class_name ExplosiveBarrel extends Area3D

@onready var explosion = $AnimatedSprite3D

func _ready():
	explosion.pause()

func _on_area_entered(area):
	if area is Fireball:
		explode()

func explode():
	$Sprite3D.visible = false
	explosion.visible = true
	explosion.play()
	await explosion.animation_finished
	queue_free()
