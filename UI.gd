extends Control

# Poorly made script for temporary UI

func _process(delta):
	var charge = get_node("%HealRay").charge
	var heal_target = get_node("%HealRay").heal_target
	get_node("Charge").text = "Charge: "+str(floor(charge))+"%"
	if heal_target != null:
		var health = heal_target.get_node("Health").health
		var overheal = heal_target.get_node("Health").overheal
		get_node("Healing").text = "Healing: "+str(ceil(health+overheal))
	else:
		get_node("Healing").text = "Healing: None"
