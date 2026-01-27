extends CanvasLayer

signal dialogue_finished

@onready var label = $Background/RichTextLabel
var lines = []
var current_index = 0

func start_dialogue(text_lines: Array):
	lines = text_lines
	current_index = 0
	show_line()
	visible = true
	
	# Freeze the player and enemies while talking
	get_tree().paused = true

func show_line():
	label.text = lines[current_index]

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		next_line()

func next_line():
	current_index += 1
	if current_index < lines.size():
		show_line()
	else:
		close_dialogue()

func close_dialogue():
	visible = false
	get_tree().paused = false # Unfreeze everything
	emit_signal("dialogue_finished")
	queue_free() # Destroy self after talking
