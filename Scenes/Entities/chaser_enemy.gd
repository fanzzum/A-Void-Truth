extends BaseEnemy

var speed = 130
var stop_distance = 25 # Increased slightly to prevent jitter

var attack_cooldown_time = 1.0 
var current_cooldown = 0.0
var is_attacking = false # <--- NEW: Locks the enemy state

func _physics_process(delta: float) -> void:
	if is_dying: return 

	# 1. NEW: If we are mid-attack, DO NOT MOVE.
	# This forces the animation to finish even if player dashes away.
	if is_attacking:
		return 

	# 2. Update Cooldown
	if current_cooldown > 0:
		current_cooldown -= delta

	if !check_for_player(): 
		velocity = Vector2.ZERO
		anim.play("idle")
		move_and_slide()
		return
	
	# 3. MOVEMENT LOGIC
	if player_ref:
		var dist = global_position.distance_to(player_ref.global_position)
		
		# If outside range, Chase
		if dist > stop_distance:
			velocity = global_position.direction_to(player_ref.global_position) * speed
			anim.play("run")
			move_and_slide() # Only move if chasing
		
		# If inside range, Try to Attack
		else:
			velocity = Vector2.ZERO
			# Only attack if cooldown is ready
			if current_cooldown <= 0:
				start_attack()

func start_attack():
	is_attacking = true
	
	# NOTE: In your SpriteFrames, your attack animation is named "hit". 
	# I recommend renaming it to "attack" in the editor later!
	anim.play("hit") 
	
	# 1. WINDUP: Wait for the "Impact Frame" (e.g. 0.4 seconds)
	# This prevents instant damage.
	await get_tree().create_timer(0.4).timeout
	
	# 2. CHECK HITBOX: Only damage if player is STILL there
	check_hitbox_damage()
	
	# 3. RECOVERY: Wait for animation to finish playing
	if anim.is_playing():
		await anim.animation_finished
		
	# 4. RESET
	current_cooldown = attack_cooldown_time
	is_attacking = false

func check_hitbox_damage():
	# This runs 0.4s AFTER the animation starts
	var bodies = $Hitbox.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("Player") and body.has_method("take_damage"):
			# Apply damage now
			body.take_damage(damage_to_player)
			# Optional: Knockback could go heress
