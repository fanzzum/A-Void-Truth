extends CanvasLayer

@onready var health_bar = $MainControl/HealthBar
@onready var bar_daydreamer = $MainControl/ConnectionBars/DayDreamer
@onready var bar_pattern = $MainControl/ConnectionBars/PatternSeeker
@onready var bar_blood = $MainControl/ConnectionBars/BloodRush
@onready var bar_mimic = $MainControl/ConnectionBars/Mimic
@onready var status_list = $MainControl/StatusList


# Glitch Effect Variables
var is_glitching = false
var original_positions = {}

func _ready() -> void:
	# Store original positions for the shake effect
	original_positions[health_bar] = health_bar.position
	
	# Connect to the update signal
	GameManager.stats_updated.connect(update_ui)
	
	# Run once to set initial values
	update_ui()

func _process(delta: float) -> void:
	# 1. UPDATE HEALTH (Poll player directly)
	# We poll HP because Player takes damage frequently without always emitting global signals
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		health_bar.max_value = GameManager.player_max_hp
		health_bar.value = player.current_hp
	
	# 2. VOID GLITCH EFFECT
	if GameManager.is_void_level:
		apply_glitch_shake()

func update_ui():
	# Update Connection Bars from GameManager
	bar_daydreamer.value = GameManager.personalities["DayDreamer"]
	bar_pattern.value = GameManager.personalities["PatternSeeker"]
	bar_blood.value = GameManager.personalities["BloodRush"]
	bar_mimic.value = GameManager.personalities["Mimic"]
	update_status_list()


func update_status_list():
	# 1. Clear old labels
	for child in status_list.get_children():
		child.queue_free()
	
	# 2. Check GameManager and add Labels
	
	# --- BUFFS ---
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

	# --- NERFS / SACRIFICES ---
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
	status_list.add_child(label)


func apply_glitch_shake():
	# Randomly shake the bars slightly to simulate instability
	var shake_amount = 2.0
	var offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
	
	health_bar.position = original_positions[health_bar] + offset
	
	# Optional: Randomly change bar colors or visibility for extra "glitch"
	if randf() < 0.05: # 5% chance per frame to flicker
		health_bar.modulate = Color(10, 0, 0) # Flash RED bright
	else:
		health_bar.modulate = Color.WHITE
