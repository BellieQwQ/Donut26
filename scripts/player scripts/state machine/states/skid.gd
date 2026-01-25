extends State

func on_enter_state():
	actor.torso_animator.play("Skid")
	print("Entering state: " + str(state_machine.current_state))

func on_physics(delta):
	if actor.jump_buffer_timer > 0 and actor.is_on_floor():
		actor.jump_buffer_timer = 0
		state_machine.on_state_change("Jump")
		return

	if !actor.is_on_floor():
		state_machine.on_state_change("Fall")
		return

	actor.velocity.x = move_toward(actor.velocity.x, 0, actor.SKID_FRICTION * delta)

	if is_equal_approx(actor.velocity.x, 0) or abs(actor.velocity.x) < 5:
		if actor.direction != 0:
			if actor.isSprinting:
				state_machine.on_state_change("Sprint")
			else:
				state_machine.on_state_change("Walk")
		else:
			state_machine.on_state_change("Idle")
		return

	if actor.direction != 0 and sign(actor.direction) == sign(actor.velocity.x):
		if actor.isSprinting:
			state_machine.on_state_change("Sprint")
		else:
			state_machine.on_state_change("Walk")
		return

	actor.move_and_slide()
