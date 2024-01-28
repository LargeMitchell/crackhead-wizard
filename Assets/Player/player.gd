extends CharacterBody3D

enum SpellBook {METH = 0, COKE = 1, LSD = 2, PCP = 3}

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
@onready var fireball : PackedScene = preload("res://Assets/Projectiles/Fireball.tscn")
@onready var lightning : PackedScene = preload("res://Assets/Projectiles/Lightning.tscn")

@onready var animated_sprite : AnimatedSprite2D = $SubViewportContainer/SubViewport/AnimatedSprite2D
@onready var raycast = $AimCast

# Player Attributes
@export var health : float = 100.0
@export var max_health : float = 100.0
@export var mana : float = 100.0
@export var max_mana : float = 200.0
@export var meth_fire_rate : float = 0.33
@export var coke_fire_rate : float = 0.66

var can_cast_spell = true
var cast_charge_timer = 999.0
var cast_charge_dur = 3.0

var cast_range : float = 40.0
var fire_timer : float = 0.0

var killed_enemy = false

var buffs : Dictionary = {
	SpellBook.METH:{"duration":30.0,"doses":1}
}
@onready var book_icons: Dictionary = {
	SpellBook.METH: {"node": $SubViewportContainer/SubViewport/LeftArm/meth, "offset": Vector2(-4,-29)},
	SpellBook.COKE: {"node": $SubViewportContainer/SubViewport/LeftArm/coke, "offset": Vector2(-64,-39)},
	SpellBook.LSD: {"node": $SubViewportContainer/SubViewport/LeftArm/lsd, "offset": Vector2(-53,26)},
	SpellBook.PCP: {"node": $SubViewportContainer/SubViewport/LeftArm/pcp, "offset": Vector2(12,15)}
}
@onready var selected_spell_sparkle: AnimatedSprite2D = $SubViewportContainer/SubViewport/LeftArm/selected_spell


func SelectNextSpell():
	if buffs.is_empty(): return
	current_spell += 1
		
	while !buffs.has(current_spell):
		if current_spell >= 4:
			current_spell = 0
		else:
			current_spell += 1

	selected_spell_sparkle.offset = book_icons[current_spell]["offset"]

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
		SelectNextSpell()
		
		
		#current_spell = Spells.new().SpellBook.COKE
	if Input.is_action_just_pressed("cast_spell"):
		cast_charge_timer = 0.0
		if current_spell == SpellBook.PCP:
			$SubViewportContainer/SubViewport/Telekinesis.show()

	if Input.is_action_just_released("cast_spell"):
		cast_spell(current_spell, cast_charge_timer)
		$SubViewportContainer/SubViewport/Telekinesis.hide()

func _ready():
	# Locks cursor to game screen
	current_spell = 0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$SubViewportContainer/SubViewport/Death.hide()
	$SubViewportContainer/SubViewport/Telekinesis.hide()
	$SubViewportContainer/SubViewport/Approach.hide()
	$SubViewportContainer/SubViewport/ApproachWyvern.hide()
	$SubViewportContainer/SubViewport/ApproachTroll.hide()
	selected_spell_sparkle.offset = book_icons[current_spell]["offset"]

var fire_anim_state: int = 0;
var cutscene_timer = 0.0
var reset = false

func play_cutscene(i : int):

	reset = false

	print(i)
	match i:
		0:
			$SubViewportContainer/SubViewport/Approach.show()
			cutscene_timer = 4.0
		1:
			$SubViewportContainer/SubViewport/ApproachWyvern.show()
			cutscene_timer = 4.0
		2:
			$SubViewportContainer/SubViewport/ApproachTroll.show()
			cutscene_timer = 4.0

var dead = false
var deadTimer = 0.0

func _process(delta):
	
	if dead:
		deadTimer += delta
		if deadTimer >= 1.0:
			$SubViewportContainer/SubViewport/Death.show()
		if deadTimer >= 2.0:
			get_tree().reload_current_scene()
		return
	
	cast_charge_timer += delta
	manage_buffs(delta)


	cutscene_timer -= delta
	if cutscene_timer <= 0.0 && !reset:
		$SubViewportContainer/SubViewport/Approach.hide()
		$SubViewportContainer/SubViewport/ApproachWyvern.hide()
		$SubViewportContainer/SubViewport/ApproachTroll.hide()
		reset = true

	if Input.is_action_just_pressed("cast_spell"):
		fire_anim_state = 1
		animated_sprite.frame = 0

	match fire_anim_state:
		0:
			animated_sprite.play("Idle")
		1:
			animated_sprite.play("GearingUp")

			if animated_sprite.frame >= 3:
				if Input.is_action_pressed("cast_spell"):
					fire_anim_state = 2
				else:
					fire_anim_state = 0
		2:
			animated_sprite.play("Firing")
			if animated_sprite.frame >= 5:
				if !Input.is_action_pressed("cast_spell"):
					fire_anim_state = 0


func _physics_process(delta):

	weapon_cooldown(delta)

	raycast.target_position = -campivot.transform.basis.z * cast_range

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		if buffs.has(SpellBook.LSD):
			velocity.y = clamp(velocity.y, -1.0, 10000.0)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if buffs.has(SpellBook.LSD):
			velocity.y = jump_velocity * 2.0
		else:
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

func take_damage(damage: float):
	#print('health', health)
	health -= damage
	if health <= 0:
		health = 0
		die()

func die():
	dead = true

func cast_spell(spell, charge: float):
	if !can_cast_spell:
		print(can_cast_spell)
		return
	if !buffs.has(spell):
		return

	match spell:
		SpellBook.METH:
			cast_meth_spell(charge)
			can_cast_spell = false

		SpellBook.COKE:
			cast_coke_spell()
			can_cast_spell = false

		SpellBook.LSD:
			cast_lsd_spell()

func cast_meth_spell(charge: float):
	spawn_projectile(fireball, charge)

func cast_coke_spell():
	spawn_lightning()


func cast_lsd_spell():
	print("lsd")

func add_to_buffs(buff: int, duration: float, max_duration: float):
	
	var empty = buffs.is_empty()

	if buffs.has(buff):
		buffs[buff]['doses'] += 1
		buffs[buff]['duration'] += duration / buffs[buff]['doses']
	else:
		buffs[buff] = {'duration': duration, 'doses': 1}
		
	if empty:
		SelectNextSpell()

func manage_buffs(delta):
	if buffs.is_empty():
		can_cast_spell = false
		return
	#can_cast_spell = true
	for key in buffs:
		#print (key," - ", buffs[key]['duration'])
		buffs[key]['duration'] -= delta
		book_icons[key]["node"].material.set_shader_parameter("threshhold", remap(buffs[key]['duration'], 0.0, 30.0, 0.0, 1.0))
		if buffs[key]['duration'] <= 0:
			buffs.erase(key)
			SelectNextSpell()

func cast_spell_anim_done():
	can_cast_spell = true

func spawn_projectile(proj: PackedScene, charge: float):

	# instantiates and spawn projectile
	var p = proj.instantiate()
	p.charge_value = charge
	owner.add_child(p)
	p.set_charge_scale()

	# sets projectile position and launch direction
	p.transform = bulletorigin.global_transform
	if raycast.is_colliding():
		p.direction = Vector3(raycast.get_collision_point() - bulletorigin.global_position).normalized()
	else:
		p.direction = -campivot.transform.basis.z

func spawn_lightning():
	var l = lightning.instantiate()
	owner.add_child(l)
	if raycast.is_colliding():
		l.transform.origin = raycast.get_collision_point()
	else:
		l.transform.origin = bulletorigin.global_position

	l.scale = l.scale * 3.0

func weapon_cooldown(delta):
	if !can_cast_spell:
		match current_spell:
			SpellBook.METH:
				if fire_timer < meth_fire_rate:
					fire_timer += delta
				else:
					fire_timer = 0.0
					can_cast_spell = true


			SpellBook.COKE:
				if fire_timer < coke_fire_rate:
					fire_timer += delta
				else:
					fire_timer = 0.0
					can_cast_spell = true

