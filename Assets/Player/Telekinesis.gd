extends AnimatedSprite2D

var tc
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

func _ready():
	tc = $"../../../TelekenesisComponent"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
