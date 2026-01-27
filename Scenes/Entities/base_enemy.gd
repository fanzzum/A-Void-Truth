extends CharacterBody2D
class_name BaseEnemy
@export_group("Aggro Settings")
@export var detection_range: float = 250.0  # Range to start chasing
var is_aggro: bool = false


@export var damage_to_player = 10
var hp = 100
var player_ref = null
var is_dying = false

# Get reference to the new AnimatedSprite2D
# Make sure the node in your scene is named "AnimatedSprite2D"
@onready var anim = $AnimatedSprite2D 

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("Player")
	if GameManager.thermal_vision:
		# This makes the enemy ignore shadows/darkness
		$AnimatedSprite2D.unshaded = true


func check_for_player() -> bool:
	if !player_ref or is_dying: return false
	
	var dist = global_position.distance_to(player_ref.global_position)
	if !is_aggro and dist < detection_range:
		is_aggro = true
	return is_aggro

func _process(delta: float) -> void:
	if is_dying: return

	# --- 1. ANIMATION DIRECTION (Mirroring) ---
	# Our sprites are LEFT facing by default.
	# If moving RIGHT (velocity.x > 0), we FLIP it to face right.
	if velocity.x < 0:
		anim.flip_h = true  # Face Right
	elif velocity.x > 0:
		anim.flip_h = false # Face Left (Default)

	# --- 2. THERMAL VISION (Your existing logic) ---
	if GameManager.thermal_vision:
		if material == null:
			material = CanvasItemMaterial.new()
			material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		modulate = Color(3, 0.5, 0.5) 
	else:
		if material != null: material = null 
		modulate = Color.WHITE

func take_damage(amount: float):
	hp -= amount
	
	# Play Hit Animation (if not already dying)
	if hp > 0:
		anim.play("hit")
		# Wait for hit anim to finish before returning to run? 
		# For simple AI, usually we just let the next physics frame override it to 'run'
		# unless we use an 'is_hurting' flag. For now, let's keep it simple.
	
	if hp <= 0:
		die()

func die():
	if is_dying: return # Prevent multiple calls
	is_dying = true
	
	# Stop all movement and physics immediately 
	velocity = Vector2.ZERO 
	
	# Disable collisions so the player can walk through the "corpse" 
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Force the death animation 
	anim.play("death")
	
	# Wait for animation to finish, then delete 
	await anim.animation_finished
	queue_free()
