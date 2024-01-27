extends CharacterBody3D

enum SpellBook {METH, COKE, CRACK, LSD}

# Basic movement variables
@export var speed : float = 8.0
@export var jump_velocity : float = 6.0
@export var gravity : float = 15.0
@export var acceleration : float = 8.0
@export var deceleration : float = 8.0

@export var current_spell = SpellBook.METH

@export_range(0.1, 1.0, 0.01) var mouse_sensitivity : float = 1.0

# Gets a reference to the camera pivot to apply camera rotation
@onready var campivot : Node3D = $CameraPivot
@onready var bulletorigin : Marker3D = $CameraPivot/SpellSpawn
@onready var projectile : PackedScene = preload("res://Assets/Projectiles/Projectile.tscn")

var can_cast_spell = true
var cast_charge_timer = 999.0
var cast_charge_dur = 3.0

func _input(event):

	# Quits game when escape key is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

	# Camera rotation
	if event is InputEventMouseMotion:
		campivot.rotation.y -= event.relative.x * mouse_sensitivity * 0.001
		campivot.rotation.x -= event.relative.y * mouse_sensitivity * 0.001
		campivot.rotation.x  = clamp(campivot.rotation.x, deg_to_rad(-80), deg_to_rad(89.9))

	if Input.is_action_just_pressed("change_spell"):
		pass
		#current_spell = Spells.new().SpellBook.COKE
	if Input.is_action_just_pressed("cast_spell"):
		cast_charge_timer = 0.0
		
	if Input.is_action_just_released("cast_spell"):
		print(cast_charge_timer)
		cast_spell(current_spell)

func _ready():
	# Locks cursor to game screen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var fire_anim_state: int = 0;

func _process(delta):
	
	cast_charge_timer += delta
	
	if Input.is_action_just_pressed("cast_spell"):
		fire_anim_state = 1
		$CameraPivot/AnimatedSprite3D.frame = 0
		
	match fire_anim_state:
		0: 
			$CameraPivot/AnimatedSprite3D.play("Idle")
		1: 
			$CameraPivot/AnimatedSprite3D.play("GearingUp")
			
			if $CameraPivot/AnimatedSprite3D.frame >= 3:
				if Input.is_action_pressed("cast_spell"):
					fire_anim_state = 2
				else:
					fire_anim_state = 0
		2: 
			$CameraPivot/AnimatedSprite3D.play("Firing")
			if $CameraPivot/AnimatedSprite3D.frame >= 5:
				if !Input.is_action_pressed("cast_spell"):
					fire_anim_state = 0

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

func cast_spell(spell, charge: float = 0.0):
	if !can_cast_spell:
		return
	#can_cast_spell = false

	match spell:
		SpellBook.METH:
			cast_meth_spell(charge)
		
		SpellBook.COKE:
			pass
		
		SpellBook.CRACK:
			pass
		
		SpellBook.LSD:
			pass

func cast_meth_spell(charge: float = 0.0):
	
	
	spawn_projectile(projectile, charge)
	
	#$AnimationPlayer.play("cast_spell")
	#$AnimationPlayer.connect("animation_finished", self, "cast_spell_anim_done")

func cast_spell_anim_done():
	can_cast_spell = true

func spawn_projectile(proj: PackedScene, charge: float = 0.0):
	
	# instantiates and spawn projectile
	var p = proj.instantiate()
	p.charge_value = charge
	owner.add_child(p)
	
	# sets projectile position and launch direction
	p.transform = bulletorigin.global_transform
	p.direction = -campivot.transform.basis.z

