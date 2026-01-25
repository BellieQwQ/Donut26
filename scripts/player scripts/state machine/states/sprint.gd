extends State

func on_enter_state():
	actor.legs_animator.set_deferred("visible", true)
	
	actor.jump_count = 0
	actor.torso_animator.play("Run_torso")
	actor.legs_animator.play("Run_legs")
	actor.torso_animator.speed_scale = 1.6
	actor.legs_animator.speed_scale = 1.6
	print("Entering state: " + str(state_machine.current_state))
	
func on_physics(delta):
	if Input.is_action_just_pressed("attack"):
		state_machine.on_state_change("Punch")
		return
	
	if actor.direction != 0 and sign(actor.direction) != sign(actor.velocity.x):
		if abs(actor.velocity.x) >= (actor.SPRINT_SPEED - 120):
			state_machine.on_state_change("Skid")
			return
	
	if Input.is_action_just_pressed("evasion") and abs(actor.velocity.x) >= actor.SPRINT_SPEED:
		state_machine.on_state_change("Slide")
		return
	
	if actor.jump_buffer_timer > 0 and actor.is_on_floor():
		actor.jump_buffer_timer = 0 
		state_machine.on_state_change("Jump")
		return
	
	if Input.is_action_just_released("sprint") and actor.direction != 0:
		state_machine.on_state_change("Walk")
		return
	
	if actor.velocity.y >= 0 and !actor.is_on_floor():
		state_machine.on_state_change("Fall")
		return
	
	if Input.is_action_pressed("crouch"):
		state_machine.on_state_change("Crouch")
		return
	
	var target_velocity = actor.direction * actor.SPRINT_SPEED
	
	if actor.direction != 0:
		if actor.is_on_floor():
			actor.velocity.x = move_toward(actor.velocity.x, target_velocity, actor.ACCELERATION * delta)
	else:
		if actor.is_on_floor():
			actor.velocity.x = move_toward(actor.velocity.x, target_velocity, actor.FRICTION * delta)
			if abs(actor.velocity.x) < 1:
				state_machine.on_state_change("Idle")
	
	actor.move_and_slide()
	
func on_exit_state():
		actor.torso_animator.speed_scale = 1.0
		actor.legs_animator.speed_scale = 1.0
		
		actor.legs_animator.set_deferred("visible", false)
