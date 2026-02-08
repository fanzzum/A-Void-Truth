extends Node2D

func _ready():
	# 1. Create the dialogue box
	var dialogue = load("res://Scenes/UI/DialogueUI.tscn").instantiate()
	add_child(dialogue)
	
	# 2. Define the "Tutorial" lines
	var tutorial_text = [
		"VOICE: Why are you here?",
		"VOICE: You are trapped in the Glitch. the only escape is the end , no choice except Running",
		"VOICE: Find the STATUES. Sacrifice your memories to summon our power.",
		"VOICE: But beware... if your CONNECTION drops to Zero...",
		"VOICE: The Void will consume you forever.",
	]
	
	# 3. Start it
	dialogue.start_dialogue(tutorial_text)
	$AudioStreamPlayer2D.play()


func _on_pitfall_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
