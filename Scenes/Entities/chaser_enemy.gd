extends BaseEnemy

var speed = 130
var stop_distance = 20

# ATTACK VARIABLES
var attack_cooldown_time = 1.0  # Time between attacks (1 second)
var current_cooldown = 0.0

func _physics_process(delta: float) -> void:
	if is_dying: 
		return 

	if !check_for_player(): 
		velocity = Vector2.ZERO
		anim.play("idle")
		move_and_slide()
		return
	
	# 1. HANDLE COOLDOWN TIMER
	if current_cooldown > 0:
		current_cooldown -= delta
	
	# 2. MOVEMENT & ANIMATION
	if player_ref:
		var dist = global_position.distance_to(player_ref.global_position)
		
		if dist > stop_distance:
			# Too far, chase!
			velocity = global_position.direction_to(player_ref.global_position) * speed
			anim.play("run")
		else:
			# Close enough, attack!
			velocity = Vector2.ZERO
			
			
			# 3. DEAL DAMAGE (Continuous Check)
			check_for_damage()
			
	move_and_slide()

func check_for_damage():
	# If we are still cooling down, don't bite yet
	if current_cooldown > 0: return
	
	# Ask the Hitbox: "Who is inside me right now?"
	var bodies = $Hitbox.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("Player"):
			# Found the player! Bite them.
			if body.has_method("take_damage"):
				anim.play("hit")
				body.take_damage(damage_to_player)
				
				# Reset the cooldown so we wait 1 second before biting again
				current_cooldown = attack_cooldown_time
				return # Stop checking, we already bit someone
