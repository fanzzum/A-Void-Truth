extends Node2D

func _ready():
	# 1. Create the dialogue box
	var dialogue = load("res://Scenes/UI/DialogueUI.tscn").instantiate()
	add_child(dialogue)
	
	# 2. Define the "Tutorial" lines
	var tutorial_text = [
		"VOICE: Wake up... We are the fragments of your mind.",
		"VOICE: You are trapped in the Glitch. To escape, you must survive the Loop.",
		"VOICE: Find the STATUES. Sacrifice your memories to summon our power.",
		"VOICE: But beware... if your CONNECTION drops to Zero...",
		"VOICE: The Void will consume you forever.",
		"VOICE: Now go. Break the cycle."
	]
	
	# 3. Start it
	dialogue.start_dialogue(tutorial_text)
