extends StaticBody2D

var ui_scene = preload("res://Scenes/UI/SacrificeUI.tscn")
var player_in_range = false
var is_used = false # <--- NEW FLAG

@onready var label = $Label
@onready var sprite = $Sprite2D # <--- Grab the sprite to darken it

func _ready() -> void:
	if label: label.visible = false

func _process(delta: float) -> void:
	# Check if NOT used
	if player_in_range and Input.is_action_just_pressed("interact") and not is_used:
		open_ui()
		
func open_ui():
	is_used = true # <--- Lock the statue immediately
	
	# Visual Feedback: Darken the statue to look "drained"
	sprite.modulate = Color(0.3, 0.3, 0.3) 
	if label: label.visible = false # Hide text immediately
	
	var ui = ui_scene.instantiate()
	get_tree().root.add_child(ui)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_used: # <--- Check used here too
		player_in_range = true
		if label: label.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		if label: label.visible = false
