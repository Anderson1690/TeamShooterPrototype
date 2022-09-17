extends Spatial

var heal_target = null
var charge = 0

var pressed = false

onready var particles = get_node("Particles")

func disconnect_heal_ray():
	if heal_target != null:
		heal_target.get_node("Health").being_healed.erase(self)
		heal_target = null
		
func connect_heal_ray(new_target):
	disconnect_heal_ray()
	var being_healed = new_target.get_node("Health").being_healed
	being_healed.insert(being_healed.size(),self)
	heal_target = new_target

func _input(_event):
	if Input.is_mouse_button_pressed(1) and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if pressed == true:
			return
		# Raycast to find which teammate the player wants to heal
		
		var space_state = get_world().direct_space_state
		var ray_start = global_translation+Vector3(0,5.3,0)
		var ray_end = ray_start+get_parent().looking*60
		var raycast = space_state.intersect_ray(ray_start,ray_end,[self])
		if raycast:
			# Check if the collider is in HealTargets group
			if raycast.collider.is_in_group("HealTargets"):
				# Check if the distance is less or equal to 45
				if global_translation.distance_to(raycast.collider.global_translation) <= 45:
					pressed = true
					connect_heal_ray(raycast.collider)
				else:
					disconnect_heal_ray()
			else:
				disconnect_heal_ray()
		else:
			disconnect_heal_ray()
	else:
		pressed = false

func _ready():
	pass

func _process(delta):
	# If there's a heal target, charge.
	if heal_target != null:
		var max_overheal = heal_target.get_node("Health").max_overheal
		var overheal = heal_target.get_node("Health").overheal
		# Charge builds at 2.5% per second (40 seconds to fully charge)
		var charge_rate = 2.5
		if overheal/max_overheal >= 0.85:
			# Charge is halved if the target has 85% or higher overheal (80 seconds)
			charge_rate = charge_rate/2
		
		charge = clamp(charge+charge_rate*delta,0,100)
		
func _physics_process(_delta):
	if heal_target != null:
		# Particles. I have absolutely no idea how particles/shaders work.
		particles.visible = true
		particles.process_material.set_shader_param("start",global_translation)
		particles.process_material.set_shader_param("end",heal_target.global_translation)
		# Disconnect if distance is higher than 54
		if global_translation.distance_to(heal_target.global_translation) > 54:
			pressed = false
			disconnect_heal_ray()
			return
		
		# Line of sight check for the heal target
		var space_state = get_world().direct_space_state
		var ray_start = global_translation
		var ray_end = heal_target.global_translation
		var raycast = space_state.intersect_ray(ray_start,ray_end,[self]+get_tree().get_nodes_in_group("HealTargets"))
		if raycast:
			pressed = false
			disconnect_heal_ray()
			return
	else:
		particles.visible = false
