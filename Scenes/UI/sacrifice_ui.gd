extends CanvasLayer

var descriptions = {
	"PatternSeeker": "\n[+25% Resist]\n[Thermal Vision]",
	"DayDreamer": "\n[+2 Bounces]\n[+15% Crit]",
	"BloodRush": "\n[+50% Damage]\n[Tunnel Vision]",
	"Mimic": "\n[Ghost Helper]\n[+Speed]"
}

@onready var sacrifice_row = $SacrificeRow
@onready var selection_row = $SelectionRow
@onready var btn_a = $SelectionRow/BtnOptionA
@onready var btn_b = $SelectionRow/BtnOptionB
@onready var btn_vision = $SacrificeRow/Button
@onready var btn_soul = $SacrificeRow/Button2
@onready var btn_legs = $SacrificeRow/Button3
var current_pair = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused =true
	# --- NEW: ANTI-EXPLOIT CHECKS ---
	
	# 1. Check Vision (Cost: 0.25, Min: 0.2)
	# If current is close to min, disable button
	if GameManager.vision_scale <= 0.25:
		btn_vision.disabled = true
		btn_vision.text = "Vision\nFractured\n(Limit Reached)"
	
	# 2. Check Soul/HP (Cost: 30, Min: 10)
	# If you have 40 or less, you can't pay 30 safely
	if GameManager.player_max_hp <= 40:
		btn_soul.disabled = true
		btn_soul.text = "Soul\nFractured\n(Limit Reached)"
		
	# 3. Check Legs/Speed (Cost: 0.15)
	# Assuming min speed is around 0.5
	if GameManager.speed_multiplier <= 0.6:
		btn_legs.disabled = true
		btn_legs.text = "Legs\nFractured\n(Limit Reached)"
	


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
	sacrifice_row.visible = false
	current_pair = GameManager.get_random_pair()
	
	var name_a = current_pair[0]
	var name_b = current_pair[1]
	
	# Update Button Text with Name + Description
	btn_a.text = "Summon \n" + name_a +"\n"+ descriptions.get(name_a, "")
	btn_b.text = "Summon \n" + name_b +"\n"+ descriptions.get(name_b, "")
	
	selection_row.visible = true
	
	
func _on_btn_option_a_pressed() -> void:
	GameManager.choose_personality(current_pair[0],current_pair[1])
	close_menu()


func _on_btn_option_b_pressed() -> void:
	GameManager.choose_personality(current_pair[1],current_pair[0])
	close_menu()
