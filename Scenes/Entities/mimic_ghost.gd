extends Node2D

var projectile_scene = preload("res://Scenes/Entities/PlayerProjectile.tscn")

# Arrays to store the "Past"
var pos_history = []
var rot_history = []
var anim_history = []
var shoot_history = []

# TWEAK 1: Increased delay (approx 0.8s at 60fps)
var delay_frames = 45 

# TWEAK 2: Distance Offset (X units behind/beside)
@export var follow_offset = Vector2(-30, -10) 

@onready var anim = $AnimatedSprite2D

func _physics_process(_delta):
	var player = get_tree().get_first_node_in_group("Player")
	
	if player and GameManager.mimic_active:
		visible = true
		
		# RECORD THE PRESENT
		pos_history.push_back(player.global_position)
		rot_history.push_back(player.weapon_pivot.rotation)
		anim_history.push_back({"name": player.anim.animation, "frame": player.anim.frame})
		shoot_history.push_back(Input.is_action_just_pressed("secondary_attack"))
		
		# REPLAY THE PAST
		if pos_history.size() > delay_frames:
			# TWEAK 3: Apply the offset so it doesn't overlap the player
			var past_pos = pos_history.pop_front()
			global_position = past_pos + follow_offset
			
			var past_rot = rot_history.pop_front()
			
			var past_anim = anim_history.pop_front()
			anim.play(past_anim["name"])
			anim.frame = past_anim["frame"]
			
			if shoot_history.pop_front() == true:
				shoot_spectral_beam(past_rot)
	else:
		visible = false

func shoot_spectral_beam(angle):
	var beam = projectile_scene.instantiate()
	beam.global_position = global_position
	beam.rotation = angle
	beam.modulate = Color(0, 1, 1) 
	get_tree().root.add_child(beam)
