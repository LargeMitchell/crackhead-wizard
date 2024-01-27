extends AnimatedSprite2D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready():
	$".".play("Idle")
	pass # Replace with function body.

var laughing_timer: float = 0.0
var laugh_duration: float = 1.0

enum wizard_state {
	GRIMACE,
	IDLE,
	SMOKING,
	ANGRY,
	DEAD
}
var wiz_state: wizard_state = wizard_state.IDLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_pressed("cast_spell") && wiz_state == wizard_state.IDLE:
		wiz_state = wizard_state.GRIMACE
		laughing_timer = 0.0
		
	if player.health <= 0.0:
		wiz_state = wizard_state.DEAD
		
	if player.killed_enemy:
		wiz_state = wizard_state.SMOKING
		
	match wiz_state:
		wizard_state.GRIMACE:
			laughing_timer += delta
			$".".play("Grimace")
			
			if laughing_timer >= laugh_duration:
				wiz_state = wizard_state.IDLE
			
		wizard_state.IDLE:
			$".".play("Idle")
		wizard_state.SMOKING:
			$".".play("Smoked")
			
		wizard_state.DEAD:
			$".".play("Death")
			pass
	
	pass
