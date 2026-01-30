extends Area2D

@export var damage = 15
@onready var anim = $AnimatedSprite2D
@onready var reset_timer = $ResetTimer
@onready var collision_shape = $CollisionShape2D

var is_triggered = false

func _ready():
	anim.play("idle") # Or the first frame where spikes are hidden

func _on_body_entered(body: Node2D):
	if is_triggered: return
	
	if body.is_in_group("Player") or body.has_method("take_damage"):
		trigger_trap(body)

func trigger_trap(victim):
	is_triggered = true
	
	# 1. Play animation
	anim.play("spike_up") # Rename to whatever your animation is called
	
	# 2. Deal Damage immediately
	if victim.has_method("take_damage"):
		victim.take_damage(damage)
	
	# 3. Wait for reset
	reset_timer.start()

func _on_reset_timer_timeout():
	# Reset the trap so it can be used again
	anim.play("idle")
	is_triggered = false


func _on_timer_timeout() -> void:
	pass # Replace with function body.
