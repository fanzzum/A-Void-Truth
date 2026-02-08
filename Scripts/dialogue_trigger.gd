extends Area2D

# 1. Allow typing lines in the Inspector
@export_multiline var dialogue_lines: Array[String] = [
	"VOICE: ...",
	"VOICE: (Add your text in the Inspector)"
]

var has_triggered = false
var ui_scene = preload("res://Scenes/UI/DialogueUI.tscn")

func _ready() -> void:
	# Ensure we only detect the player
	collision_mask = 2 # Matches Player Layer
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not has_triggered:
		has_triggered = true
		
		# 2. Spawn the Dialogue UI
		var dialogue = ui_scene.instantiate()
		get_tree().root.add_child(dialogue)
		
		# 3. Pass the specific lines for THIS trigger
		dialogue.start_dialogue(dialogue_lines)
		
		# Optional: Destroy this trigger so it can't happen again
		queue_free()
