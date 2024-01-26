class_name Player extends CharacterBody3D

# Basic movement variables
@export var speed : float = 5.0
@export var jump_velocity : float = 4.5
@export var gravity : float = 9.8
@export var acceleration : float = 5.0
@export var deceleration : float = 5.0

@export_range(0.1, 1.0, 0.01) var mouse_sensitivity : float = 1.0

# Gets a reference to the camera pivot to apply camera rotation
@onready var campivot : Node3D = $CameraPivot

func _input(event):
	
	# Quits game when escape key is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	# Camera rotation
	if event is InputEventMouseMotion:
		campivot.rotation.y -= event.relative.x * mouse_sensitivity * 0.001
		campivot.rotation.x -= event.relative.y * mouse_sensitivity * 0.001
		campivot.rotation.x  = clamp(campivot.rotation.x, deg_to_rad(-80), deg_to_rad(89.9))

func _ready():
	# Locks cursor to game screen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and rotate it based on camera rotation
	var input_dir : Vector2 = Input.get_vector("left", "right", "up", "down")
	var direction : Vector3 = Vector3(input_dir.x, 0, input_dir.y).normalized().rotated(Vector3.UP, campivot.rotation.y)
	
	# Apply input diretion as movement
	if direction:
		velocity.x = lerpf(velocity.x, direction.x * speed, delta * acceleration)
		velocity.z = lerpf(velocity.z, direction.z * speed, delta * acceleration)
	else:
		velocity.x = lerpf(velocity.x, 0, delta * deceleration)
		velocity.z = lerpf(velocity.z, 0, delta * deceleration)

	#applies velocity to kinematic body
	move_and_slide()

