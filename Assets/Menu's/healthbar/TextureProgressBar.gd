extends TextureProgressBar

@export var progressamount : float = 0.0
@onready var healthlabel : Label = $Health
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = player.health
	
	healthlabel.text = str(player.health)
