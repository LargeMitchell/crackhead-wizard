extends Area3D

# Called when the node enters the scene tree for the first time.
@export var duration: float = 10
@export var max_duration: float = 30
@export var drug_type: int

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_to_buffs(drug_type, duration, max_duration)
		queue_free()
