extends State

func on_enter_state():
	actor.torso_animator.play("Crouch")
	actor.torso_animator.scale = Vector2(1.2, 0.8)
	print("Entering state: " + str(state_machine.current_state))
	
	actor.evasion_detector.set_deferred("enabled", true)
	
	actor.set_hurtbox_size("Evasion")
	actor.set_collision_size("Evasion")
	
func on_physics(delta):
	if Input.is_action_just_pressed("evasion"):
		state_machine.on_state_change("Roll")
		return
	
	if actor.jump_buffer_timer > 0 and actor.is_on_floor() and !actor.blocked_above:
		actor.jump_buffer_timer = 0 
		state_machine.on_state_change("Jump")
		return
	
	if actor.velocity.y >= 0 and !actor.is_on_floor():
		state_machine.on_state_change("Fall")
		return
	
	if actor.is_on_floor():
		actor.velocity.x = move_toward(actor.velocity.x, 0, actor.FRICTION * delta)
	
	if Input.is_action_just_released("crouch"): 
		
		if actor.direction != 0 and !actor.blocked_above:
			if actor.isSprinting:
				state_machine.on_state_change("Sprint")
			else:
				state_machine.on_state_change("Walk")
		else:
			if Input.is_action_pressed("crouch") or actor.blocked_above:
				return
			elif !actor.blocked_above:
				state_machine.on_state_change("Idle")
	
	actor.move_and_slide()
	
func on_exit_state():
	actor.evasion_detector.set_deferred("enabled", false)
	
	actor.set_hurtbox_size("Stand")
	actor.set_collision_size("Stand")
