extends Node

export(float) var max_health = 125
export(float) var health = 125
var injured_timer = -10

var max_overheal = 0
export(float) var overheal = 0

var being_healed = []

onready var display = get_parent().get_node("DisplayHealth")

func calc_max_overheal(value):
	# Max overheal is 1.5* max health rounded down (floor) to a multiple of 5
	return floor((value*0.5)/5)*5

func _ready():
	max_overheal = calc_max_overheal(max_health)
	

# I don't know how TF2 handles decimal numbers for health and healing
# My best guess is that it just displays health rounded up (ceil)

func change_total_health(value):
	# Adds health and applies overheal if value is positive
	# Reduces health and restarts critical healing if value is negative
	
	var total_health = health+overheal+value
	
	overheal = clamp(total_health-max_health,0,max_overheal)
	health = clamp(total_health-overheal,0,max_health)
	
	if value < 0:
		# Player was injured, restart critical healing
		injured_timer = -10
		

func _process(delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		injured_timer = clamp(injured_timer+delta,-10,5)
	
	if being_healed.size() > 0:
		# When being healed by a Medic:
		# 24 health per second, increases with multiple players healing the same target
		
		var heal_rate = being_healed.size()*24
		
		# Critical healing:
		# If the player has not been injured by 10 seconds,
		# the heal rate increases from 1* to 3* on 15 seconds total
		
		var crit_heal = 1+clamp((injured_timer)/5*2,0,2)
		
		
		change_total_health(heal_rate*crit_heal*delta)
	else:
		# Decay Overheal:
		# It takes 15 seconds without healing for Overheal to fully decay
		
		var decay_rate = max_overheal/15
		
		overheal = clamp(overheal-decay_rate*delta,0,max_overheal)
		
	# Temporary health display code.
	display.text = str(ceil(health+overheal))
	if health+overheal > max_health:
		display.modulate = Color(0,1,0)
	elif health+overheal <= max_health*0.75:
		display.modulate = Color(1,0,0)
	else:
		display.modulate = Color(1,1,1)
