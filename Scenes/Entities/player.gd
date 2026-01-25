extends CharacterBody2D

var projectile_scene = preload("res://Scenes/Entities/PlayerProjectile.tscn")
# EXPORT VARIABLES: Tweak these in the Inspector!
@export_group("Movement")
@export var speed: float = 120.0
@export var dash_speed: float = 300.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5


@onready var weapon_pivot = $WeaponPivot
@onready var muzzle = $WeaponPivot/Muzzle
@onready var melee_hitbox = $WeaponPivot/MeleeHitbox/CollisionShape2D
@onready var light = $PointLight2D

var can_dash : bool = true
var is_dashing : bool = false
var is_attacking : bool = false

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if is_dashing:
		velocity=direction*dash_speed
	elif direction:
		velocity=direction*speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO,speed)
		
	move_and_slide()
	
	weapon_pivot.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		melee_swing()
		
	if Input.is_action_just_pressed("secondary_attack") and not is_attacking:
		shoot()
	
	if Input.is_action_just_pressed("dash") and can_dash and direction!=Vector2.ZERO:
		start_dash()
		
		
func shoot():
	var beam = projectile_scene.instantiate()
	beam.global_position = muzzle.global_position
	beam.rotation = weapon_pivot.rotation
	get_tree().root.add_child(beam)
	
	
func melee_swing():
	is_attacking = true
	melee_hitbox.disabled = false
	
	# Simple "Swing" animation using Tween
	var tween = create_tween()
	# Rotate staff down slightly
	tween.tween_property(weapon_pivot, "rotation_degrees", weapon_pivot.rotation_degrees + 40, 0.1)
	# Rotate staff up (The hit)
	tween.tween_property(weapon_pivot, "rotation_degrees", weapon_pivot.rotation_degrees - 40, 0.1)
	
	await tween.finished
	
	melee_hitbox.disabled = true # Turn off Hitbox
	is_attacking = false
		
		
		
func start_dash():
	#two states to implement dash cooldown
	can_dash=false
	is_dashing=true
	
	set_collision_mask_value(2,false)
	
	#pauses this function until dash is finished
	await get_tree().create_timer(dash_duration).timeout
	
	is_dashing=false
	set_collision_layer_value(2,true)
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash =true
	
func set_vision_scale(scale_amount : float):
	light.texture_scale = scale_amount
	
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
