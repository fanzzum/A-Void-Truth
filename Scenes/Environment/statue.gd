extends StaticBody2D


var ui_scene = preload("res://Scenes/UI/SacrificeUI.tscn")
var player_in_range = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range:print("in range")
	if Input.is_action_just_pressed("interact"): print("interacteddsd")
	if player_in_range and Input.is_action_just_pressed("interact"):
		open_ui()
		
		
func open_ui():
	var ui = ui_scene.instantiate()
	get_tree().root.add_child(ui)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range=true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range=false
