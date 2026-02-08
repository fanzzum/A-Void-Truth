extends Area2D

var speed = 600
var damage = 50
var current_bounces = 0

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta

func _ready() -> void:
	current_bounces = GameManager.bounce_count

func _on_area_entered(area: Area2D) -> void:
	# layer 6 (Value 32) is usually enemy projectiles
	if area.collision_layer == 32:
		area.queue_free()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# 1. Handle TileMaps (Walls)
	if body is TileMap:
		if current_bounces > 0:
			perform_bounce()
		else:
			# No bounces left? It hits the wall and disappears.
			queue_free()
		return

	# 2. Handle Enemies
	if body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		
		if current_bounces > 0:
			perform_bounce()
		else:
			# No bounces left? It hits the enemy and disappears.
			queue_free()
		return

	# 3. Everything Else (Decoration, Props, etc.)
	# If it's not a wall or an enemy, we do NOTHING.
	# This lets the beam fly over/through it without disappearing.

func perform_bounce():
	current_bounces -= 1
	# Reverse direction with a slight random spread
	rotation_degrees += 180 + randf_range(-45, 45)
	# Push out slightly to avoid getting stuck in the wall
	position += Vector2.RIGHT.rotated(rotation) * 20
