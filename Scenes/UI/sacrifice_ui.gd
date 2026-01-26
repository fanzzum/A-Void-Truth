extends CanvasLayer

@onready var sacrifice_row = $SacrificeRow
@onready var selection_row = $SelectionRow
@onready var btn_a = $SelectionRow/BtnOptionA
@onready var btn_b = $SelectionRow/BtnOptionB

var current_pair = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused =true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	GameManager.sacrifice_eye()
	advance_to_stage_2()


func _on_button_2_pressed() -> void:
	GameManager.sacrifice_soul()
	advance_to_stage_2()


func _on_button_3_pressed() -> void:
	GameManager.sacrifice_legs()
	advance_to_stage_2()
	
func close_menu():
	get_tree().paused=false
	queue_free()

func advance_to_stage_2():
	sacrifice_row.visible=false
	current_pair = GameManager.get_random_pair()
	btn_a.text = "Summon \n" + current_pair[0]
	btn_b.text = "Summon \n" + current_pair[1]
	selection_row.visible = true

func _on_btn_option_a_pressed() -> void:
	GameManager.choose_personality(current_pair[0],current_pair[1])
	close_menu()


func _on_btn_option_b_pressed() -> void:
	GameManager.choose_personality(current_pair[1],current_pair[0])
	close_menu()
