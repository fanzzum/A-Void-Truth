extends CanvasLayer

# --- NODE REFERENCES ---
@onready var health_bar = $MainControl/HealthBar
@onready var status_list = $MainControl/StatusList
@onready var void_overlay = $VoidOverlay

# Updated paths for the HBoxContainer rows
@onready var bar_daydreamer = $MainControl/ConnectionBars/DayDreamerRow/DayDreamer
@onready var bar_pattern = $MainControl/ConnectionBars/PatternSeekerRow/PatternSeeker
@onready var bar_blood = $MainControl/ConnectionBars/BloodRushRow/BloodRush
@onready var bar_mimic = $MainControl/ConnectionBars/MimicRow/Mimic

# --- VARIABLES ---
var previous_values = {
	"PatternSeeker": 0,
	"DayDreamer": 0,
	"BloodRush": 0,
	"Mimic": 0
}

var original_positions = {}

func _ready() -> void:
	# Store original positions for the shake effect
	original_positions[health_bar] = health_bar.position
	
	# Connect to GameManager signal
	GameManager.stats_updated.connect(update_ui)
	
	# Initialize history to current values to prevent "Recalled" messages on start
	previous_values = GameManager.personalities.duplicate()
	
	update_ui()

func _process(_delta: float) -> void:
	# 1. VOID OVERLAY VISIBILITY
	void_overlay.visible = GameManager.is_void_level
	
	# 2. UPDATE HEALTH (Direct polling)
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		health_bar.max_value = 100
		health_bar.value = player.current_hp
	
	# 3. VOID GLITCH EFFECT
	if GameManager.is_void_level:
		apply_glitch_shake()

func update_ui():
	# Update Connection Bar values
	bar_daydreamer.value = GameManager.personalities["DayDreamer"]
	bar_pattern.value = GameManager.personalities["PatternSeeker"]
	bar_blood.value = GameManager.personalities["BloodRush"]
	bar_mimic.value = GameManager.personalities["Mimic"]
	
	update_status_list()
	
	# Save current values for next comparison
	previous_values = GameManager.personalities.duplicate()

func update_status_list():
	# Clear old labels
	for child in status_list.get_children():
		child.queue_free()
	
	# --- NARRATIVE UPDATES ---
	for p_name in GameManager.personalities.keys():
		var current = GameManager.personalities[p_name]
		var prev = previous_values.get(p_name, 0)
		
		if current != prev:
			if current == 100:
				add_status_label(p_name + " has been remembered.", Color.GOLD)
			elif current == 0:
				add_status_label(p_name + " has been forgotten.", Color.DIM_GRAY)
			elif current > prev:
				add_status_label(p_name + " has been recalled.", Color.GREEN_YELLOW)
			elif current < prev:
				add_status_label(p_name + " memory became more vague.", Color.ORANGE_RED)

	if status_list.get_child_count() > 0:
		add_status_label("----------------", Color.WHITE)

	# --- BUFFS & NERFS DISPLAY ---
	if GameManager.thermal_vision:
		add_status_label("Thermal Vision", Color.CYAN)
	
	if GameManager.bounce_count > 0:
		add_status_label("Bouncing Beams x" + str(GameManager.bounce_count), Color.PINK)
		
	if GameManager.mimic_active:
		add_status_label("Ghost Active", Color.WHITE)
		
	if GameManager.is_blood_rushed:
		add_status_label("BLOOD RUSH", Color.RED)
		
	if GameManager.crit_chance > 0:
		add_status_label("Crit: " + str(GameManager.crit_chance * 100) + "%", Color.YELLOW)

	if GameManager.vision_scale < 1.0:
		add_status_label("Partially Blind", Color.GRAY)
		
	if GameManager.player_max_hp < 100:
		add_status_label("Soul Fractured", Color.PURPLE)
		
	if GameManager.speed_multiplier < 1.0:
		add_status_label("Fragile Leg", Color.BROWN)

func add_status_label(text: String, color: Color):
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	status_list.add_child(label)

func apply_glitch_shake():
	# Random shake logic
	var shake_amount = 2.0
	var offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	health_bar.position = original_positions[health_bar] + offset
	
	# Flicker effect
	if randf() < 0.05:
		health_bar.modulate = Color(10, 0, 0) # Over-bright red
	else:
		health_bar.modulate = Color.WHITE
