extends Area2D

var speed = 600
var damage = 25
var current_bounces =0

func _physics_process(delta: float) -> void:
	#faces where the node is facing
	var direction = Vector2.RIGHT.rotated(rotation)
	position+=direction*speed*delta
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_bounces = GameManager.bounce_count


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	#layer 6
	if area.collision_layer==32:
		#destroy enemy bullet
		area.queue_free()
		#disappear after hitting
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.collision_layer ==1:
		if current_bounces>0:
			perform_bounce()
		else:queue_free()
		
	elif body.has_method("take_damage"):
		body.take_damage(damage)
		if current_bounces>0:
			perform_bounce()
		else:queue_free()

func perform_bounce():
	current_bounces-=1
	rotation_degrees+=180 + randf_range(-45,45)
	position += Vector2.RIGHT.rotated(rotation) * 20
