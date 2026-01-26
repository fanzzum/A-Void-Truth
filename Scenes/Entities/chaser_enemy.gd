extends BaseEnemy

var speed = 80




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	if player_ref:
		velocity = global_position.direction_to(player_ref.global_position)*speed
	move_and_slide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
