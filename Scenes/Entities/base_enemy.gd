extends CharacterBody2D
class_name BaseEnemy

var hp =100
var player_ref = null
var is_flashing = false


func take_damage(amount: float):
	hp -= amount
	
	# Damage Flash Logic
	is_flashing = true
	var previous_modulate = modulate # Remember current color (Red or White)
	
	modulate = Color(10, 10, 10) # Flash Bright White
	await get_tree().create_timer(0.05).timeout
	
	modulate = previous_modulate # Go back to previous color
	is_flashing = false
	
	if hp <= 0:
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_flashing:return
	
	if GameManager.thermal_vision:
		# Option B: "Ignore Point2D" (Make them visible in pitch black)
		# We create a new material on the fly if one doesn't exist
		if material == null:
			material = CanvasItemMaterial.new()
			material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	else:
		# Reset to normal
		modulate = Color.WHITE
		if material != null:
			material = null # Go back to being affected by shadows
