extends StaticBody2D

#makes the option of next level path appear in inspector
@export_file("*.tscn") var next_level_path

var player_in_range = false
@onready var label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if label:label.visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("leave_level"):
		go_next_level()

func go_next_level():
	get_tree().change_scene_to_file(next_level_path)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		label.visible =true
		player_in_range=true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		label.visible =false
		player_in_range=false
