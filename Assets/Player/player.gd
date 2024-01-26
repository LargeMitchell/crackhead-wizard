class_name Player extends CharacterBody3D

@export var speed : float = 5.0
@export var jump_velocity : float = 4.5
@export var gravity : float = 9.8

@onready var campivot : Node3D = $CameraPivot

func _input(event):
	
	#quits game when escape key is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	#camera rotation
	if event is InputEventMouseMotion:
		campivot.rotation.y -= event.relative.x * 0.001
		campivot.rotation.x -= event.relative.y * 0.001
		campivot.rotation.x  = clamp(campivot.rotation.x, deg_to_rad(-80), deg_to_rad(89.9))


func _ready():
	
	#locks cursor to game screen
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
	var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized().rotated(Vector3.UP, campivot.rotation.y)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
