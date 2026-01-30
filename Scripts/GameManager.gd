extends Node

var player_max_hp = 100.0
var vision_scale = 1.0
var speed_multiplier = 1.0
var dash_cooldown_multiplier = 1.0
var damage_multiplier = 1.0
var hp_cost_beam = 2.0

#tell player and UI to refresh
signal stats_updated

var personalities={
	"Mimic":40,
	"DayDreamer":40,
	"BloodRush":40,
	"PatternSeeker":40
}

var bounce_count = 0
var crit_chance =0

var damage_resistance = 0.0
var thermal_vision = false

var is_blood_rushed = false
var mimic_active = false

var is_void_level = false


func sacrifice_eye():
	vision_scale-=0.25
	if vision_scale<=0.2:vision_scale=0.2
	print("Eye has been Sacrificed .vision is now : ",vision_scale)
	emit_signal("stats_updated")
	
	
func sacrifice_soul():
	player_max_hp-=30
	print("Soul has been Sacrificed .soul is now : ",player_max_hp)
	emit_signal("stats_updated")


func sacrifice_legs():
	speed_multiplier-=0.15
	dash_cooldown_multiplier+=0.5
	print("leg has been Sacrificed .speed is now : ",speed_multiplier," and cooldown is ",dash_cooldown_multiplier)
	emit_signal("stats_updated")


func get_random_pair():
	var keys = personalities.keys()
	keys.shuffle()
	return [keys[0],keys[1]]
	
	
func choose_personality(chosen:String,rejected:String):
	# 1. Update Connection Bars
	personalities[chosen] += 25
	personalities[rejected] -= 15
	
	if personalities[chosen] > 100: personalities[chosen] = 100
	if personalities[rejected] <= 0: 
		personalities[rejected] = 0
		is_void_level = true
		print("VOID STATE TRIGGERED")

	# 2. Apply Powers
	apply_powers(chosen)
	emit_signal("stats_updated") # Update Player now
	
	
	
func apply_powers(name: String):
	match name:
		"PatternSeeker": # CHANGED from "Pattern" to match Dictionary
			damage_resistance += 0.25 
			thermal_vision = true     
			print("Pattern: Resistance Up + Thermal Vision")

		"DayDreamer": # CHANGED to match Dictionary (Case Sensitive!)
			bounce_count += 2    
			crit_chance += 0.15  
			print("Daydreamer: +2 Bounce + 15% Crit")

		"Mimic":
			mimic_active = true
			print("Mimic: Ghost Active")

		"BloodRush": # CHANGED from "Blood" to match Dictionary
			damage_multiplier += 1.5 
			vision_scale = 0.5 
			is_blood_rushed = true 
			print("Blood: Violence Active")

func reset_run():
	player_max_hp = 100.0
	vision_scale = 1.0
	speed_multiplier = 1.0
	dash_cooldown_multiplier = 1.0
	emit_signal("stats_updated")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
