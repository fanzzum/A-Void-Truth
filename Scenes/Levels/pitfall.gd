extends Area2D

func _physics_process(delta: float) -> void:
	# Get everyone currently standing on the hole
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("Player"):
			# If the player is inside AND the dash has finished -> DIE
			if not body.is_dashing: 
				print("Player landed in the void!")
				if body.has_method("die"):
					body.die()
