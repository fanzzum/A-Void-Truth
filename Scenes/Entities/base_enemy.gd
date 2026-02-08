extends CharacterBody2D
class_name BaseEnemy

@export_group("Aggro Settings")
@export var detection_range: float = 250.0  # Range to start chasing
var is_aggro: bool = false

@export_group("Visuals")
@export var visual_offset_x: float = 0.0 # Fixes sprite centering issues (Set to 38 for Goblin)

@export var damage_to_player = 20
var hp = 100
var player_ref = null
var is_dying = false

# Get reference to the AnimatedSprite2D
@onready var anim = $AnimatedSprite2D 

func _ready() -> void:
	add_to_group("Enemy")
	player_ref = get_tree().get_first_node_in_group("Player")
	
	# Apply the initial offset so it doesn't jump on the first frame
	if anim:
		anim.position.x = visual_offset_x
		
	if GameManager.thermal_vision:
		# This makes the enemy ignore shadows/darkness
		if anim.material == null:
			anim.material = CanvasItemMaterial.new()
		anim.material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED #

func check_for_player() -> bool:
	if !player_ref or is_dying: return false
	
	var dist = global_position.distance_to(player_ref.global_position)
	if !is_aggro and dist < detection_range:
		is_aggro = true
	return is_aggro

func _process(delta: float) -> void:
	if is_dying: return

	# --- 1. ANIMATION DIRECTION & OFFSET FIX ---
	# Adjust the +/- signs here if your enemy faces the wrong way!
	
	if velocity.x < 0:
		# Moving Left
		anim.flip_h = true  
		# When flipping, we invert the position to keep the sprite centered
		anim.position.x = -visual_offset_x 
		
	elif velocity.x > 0:
		# Moving Right
		anim.flip_h = false 
		# Reset to the normal offset
		anim.position.x = visual_offset_x 

	# --- 2. THERMAL VISION ---
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
	
	# --- START FLASH LOGIC ---
	var tween = create_tween()
	# Set modulate to a very high value to make it "glow" white
	anim.modulate = Color(10, 10, 10, 1) 
	
	# Smoothly transition back to standard or thermal color
	var target_color = Color(3, 0.5, 0.5) if GameManager.thermal_vision else Color.WHITE
	tween.tween_property(anim, "modulate", target_color, 0.1)
	# --- END FLASH LOGIC ---
	
	# Play Hit Animation (if not already dying)
	if hp > 0:
		anim.play("hit")
	
	if hp <= 0:
		die()

func die():
	if is_dying: return # Prevent multiple calls
	is_dying = true
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		# Heal the player for 5 HP (soul) per kill
		player.current_hp = min(player.current_hp + 12.0, GameManager.player_max_hp)
	
	# Stop all movement and physics immediately 
	velocity = Vector2.ZERO 
	
	# Disable collisions so the player can walk through the "corpse" 
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Force the death animation 
	anim.play("death")
	
	# Wait for animation to finish, then delete 
	await anim.animation_finished
	queue_free()
