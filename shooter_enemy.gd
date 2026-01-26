extends BaseEnemy

var bullet_scene  = preload("res://Scenes/Entities/EnemyProjectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("Player")
	var timer = Timer.new()
	#timer repeats by default , if not default you gotta set it to oneshot
	timer.wait_time =2.0
	timer.autostart = true
	timer.timeout.connect(shoot_at_player)
	add_child(timer)
	
func shoot_at_player():
	if player_ref:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.look_at(player_ref.global_position)
		get_tree().root.add_child(bullet)
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
