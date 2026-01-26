extends Area2D


var speed = 250
var damage = 10

func _physics_process(delta: float) -> void:
	
	#transform.x means whatever direction the node is currently facing
	position = position+transform.x*speed*delta

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name=="Player" :
		print("Player Hit")
		queue_free()
	elif body.collision_layer == 1:
		queue_free()
