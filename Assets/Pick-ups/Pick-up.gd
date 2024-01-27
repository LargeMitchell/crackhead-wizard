class_name PickUp extends Area3D

# Called when the node enters the scene tree for the first time.
@export var mana: float

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.mana += mana
		body.mana = clamp(body.mana,0,body.max_mana)
		print(body.mana)
		queue_free()
