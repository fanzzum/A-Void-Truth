extends CharacterBody2D

var projectile_scene = preload("res://Scenes/Entities/PlayerProjectile.tscn")
# EXPORT VARIABLES: Tweak these in the Inspector!
@export_group("Movement")
@export var speed: float = 280.0
@export var dash_speed: float = 520.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5
@export var current_hp = 0.0

@onready var weapon_pivot = $WeaponPivot
@onready var muzzle = $WeaponPivot/Muzzle
@onready var melee_hitbox = $MeleeHitbox/CollisionShape2D
@onready var light = $PointLight2D
@onready var anim = $AnimatedSprite2D
var can_dash : bool = true
var is_dashing : bool = false
var is_attacking : bool = false

@onready var sfx_dash = $SfxDash
@onready var sfx_slash = $SfxSlash
@onready var sfx_beam = $SfxBeam

func _ready() -> void:
	current_hp = GameManager.player_max_hp
	add_to_group("Player")
	melee_hitbox.disabled = true
	update_stats()
	GameManager.stats_updated.connect(update_stats)


func get_movement_dir() -> String:
	# If we aren't moving, default to aiming direction so we don't snap weirdly
	if velocity.length() == 0:
		return get_facing_direction()
		
	# Compare horizontal vs vertical speed to see which is dominant
	if abs(velocity.x) > abs(velocity.y):
		return "right" if velocity.x > 0 else "left"
	else:
		return "down" if velocity.y > 0 else "up"



func update_stats():
	set_vision_scale(GameManager.vision_scale)
	if current_hp>GameManager.player_max_hp:current_hp=GameManager.player_max_hp
	if GameManager.mimic_active and !get_tree().root.has_node("MimicGhost"):
		var ghost = load("res://Scenes/Entities/MimicGhost.tscn").instantiate()
		ghost.name = "MimicGhost"
		get_tree().root.call_deferred("add_child", ghost)
	


func _physics_process(delta: float) -> void:
	weapon_pivot.look_at(get_global_mouse_position())
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if is_dashing:
		velocity=direction*dash_speed
	elif direction:
		velocity=direction*(speed*GameManager.speed_multiplier)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,speed)
		
	move_and_slide()
	if not is_attacking:
		update_animation_state(direction)
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		melee_swing()
		
	if Input.is_action_just_pressed("secondary_attack") and not is_attacking:
		shoot()
	
	if Input.is_action_just_pressed("dash") and can_dash and direction!=Vector2.ZERO:
		start_dash()
		
	if Input.is_action_just_pressed("test"):
		GameManager.sacrifice_eye() # Test Vision Loss
		
		
		
		
func get_facing_direction() -> String:
	# Convert mouse angle to 4-direction string
	var angle = (get_global_mouse_position() - global_position).angle()
	var angle_deg = rad_to_deg(angle)
	
	if angle_deg > -45 and angle_deg <= 45:
		return "right"
	elif angle_deg > 45 and angle_deg <= 135:
		return "down"
	elif angle_deg > -135 and angle_deg <= -45:
		return "up"
	else:
		return "left"


func update_animation_state(move_input: Vector2):
	# Don't interrupt attacks or dashes
	if is_attacking or is_dashing: 
		return
	
	# CASE 1: MOVING (Use Velocity Direction)
	if velocity.length() > 0:
		var move_dir = get_movement_dir()
		anim.play("run_" + move_dir)
		
	# CASE 2: STANDING STILL (Use Mouse/Aim Direction)
	else:
		var look_dir = get_facing_direction()
		anim.play("idle_" + look_dir)

func shoot():
	if current_hp > GameManager.hp_cost_beam:
		is_attacking = true
		var face_dir = get_facing_direction()
		sfx_beam.play()
		anim.play("shoot_" + face_dir) 
		
		# 1. WAIT for the gun to actually lift up (e.g., 0.3 seconds)
		await get_tree().create_timer(0.15).timeout 
		
		# --- SPAWN PROJECTILE LOGIC STARTS HERE ---
		var beam = projectile_scene.instantiate()
		beam.global_position = muzzle.global_position
		beam.rotation = weapon_pivot.rotation
		
		var tree = get_tree()
		if tree and tree.root:
			tree.root.add_child(beam)
		
		take_damage(5)
		# --- SPAWN LOGIC ENDS ---
		
		if current_hp > 0:
			await anim.animation_finished
			is_attacking = false
	
	
# In player.gd

func melee_swing():
	is_attacking = true
	sfx_slash.play()
	
	# 1. Start the visual animation
	current_hp -=2
	var face_dir = get_facing_direction()
	anim.play("melee_" + face_dir) 
	
	# 2. WAIT for the "Swing" point (Adjust 0.3 to match your sprite!)
	# If your animation is 0.5s, the hit usually happens around 0.3s
	await get_tree().create_timer(0.3).timeout
	
	# 3. NOW enable the hitbox (Damage & Flash happen here)
	melee_hitbox.disabled = false 
	
	# 4. Keep it active for a split second (active frames)
	await get_tree().create_timer(0.1).timeout
	
	# 5. Turn it off
	melee_hitbox.disabled = true 
	
	# 6. Wait for the rest of the animation to finish cleanly
	if anim.is_playing():
		await anim.animation_finished
	
	is_attacking = false
	
	
	
func take_damage(amount):
	current_hp-=amount * (1.0 - GameManager.damage_resistance)
	if current_hp<=0:die()
	print("damage taken: ",current_hp)
		
		
func die():
	GameManager.reset_run()
	get_tree().change_scene_to_file("res://Scenes/UI/GameOver.tscn")
		
		
func start_dash():
	can_dash = false
	is_dashing = true
	sfx_dash.play()
	melee_hitbox.disabled =true
	set_collision_mask_value(2, false)
	
	# CHANGE: Use movement direction instead of mouse direction
	var move_dir = get_movement_dir()
	anim.play("dash_" + move_dir)
	
	await anim.animation_finished
	is_dashing = false
	set_collision_mask_value(2, true)
	
	await get_tree().create_timer(dash_cooldown * GameManager.dash_cooldown_multiplier).timeout
	can_dash = true

# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_melee_hitbox_body_entered(body: Node2D) -> void:
	# This function runs AUTOMATICALLY when the hitbox touches something
	
	# 1. Check if the thing we hit is an Enemy
	if body.is_in_group("Enemy") or body.has_method("take_damage"):
		
		# 2. Deal Damage
		var damage_amount = 35 # Set your melee damage here
		if body.has_method("take_damage"):
			body.take_damage(damage_amount)
			
		# Optional: Add knockback or a hit sound here
		print("Melee hit!", body.name)


func set_vision_scale(new_scale: float):
	# Directly scale the PointLight2D to change the visible area
	if light:
		light.texture_scale = new_scale
	
	# Optional: You can also adjust the light's energy for a "dimming" effect
	# light.energy = 1.27 * new_scalew
