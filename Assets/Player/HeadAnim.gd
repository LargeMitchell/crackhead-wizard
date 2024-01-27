extends AnimatedSprite2D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready():
	$".".play("Trolling")
	pass # Replace with function body.

var laughing_timer: float = 0.0
var laugh_duration: float = 1.0

enum wizard_state {
	GRIMACE,
	IDLE,
	SMOKING
}
var wiz_state: wizard_state = wizard_state.IDLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("cast_spell"):
		wiz_state = wizard_state.GRIMACE
	
	pass
