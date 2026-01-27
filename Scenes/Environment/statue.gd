extends StaticBody2D

var ui_scene = preload("res://Scenes/UI/SacrificeUI.tscn")
var player_in_range = false

# 1. Get reference to the label
@onready var label = $Label

func _ready() -> void:
	# 2. Ensure it starts hidden
	if label:
		label.visible = false

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		open_ui()
		
func open_ui():
	var ui = ui_scene.instantiate()
	get_tree().root.add_child(ui)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		# 3. Show label when player is near
		print("yo")
		if label: 
			label.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("yoy")
		player_in_range = false
		# 4. Hide label when player leaves
		if label: 
			label.visible = false
