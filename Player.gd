extends KinematicBody

# 10 Hammer Units = 1 Godot Unit
var speed = 32 
var gravity = 80

var velocity = Vector3.ZERO

var looking = Vector3.ZERO

var mouse_sensitivity = 0.002  # radians/pixel

func _unhandled_input(event):
	if event is InputEventKey and Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			 
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot/Camera.rotate_x(-event.relative.y * mouse_sensitivity)
		$Pivot/Camera.rotation.x = clamp($Pivot/Camera.rotation.x, -1.2, 1.2)
		looking = $Pivot/Camera.global_transform.basis.xform(Vector3.FORWARD)

# This needs a lot of improvement, but this isn't my objective right now
func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction += $Pivot.global_transform.basis.x
	if Input.is_action_pressed("ui_left"):
		direction -= $Pivot.global_transform.basis.x
	if Input.is_action_pressed("ui_down"):
		direction += $Pivot.global_transform.basis.z
	if Input.is_action_pressed("ui_up"):
		direction -= $Pivot.global_transform.basis.z
		
	if Input.is_action_just_pressed("ui_select"):
		print(is_on_floor())
		if is_on_floor():
			velocity.y = 30
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y -= gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	


