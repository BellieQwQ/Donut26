extends State

func on_enter_state():
	actor.set_hurtbox_size("Stand")
	actor.set_collision_size("Stand")
	actor.torso_animator.play("Land")
	actor.torso_animator.scale = Vector2(1.3, 0.7)
	actor.jump_count = 0
	print("Entering state: " + str(state_machine.current_state))

func on_physics(delta):
	if actor.direction != 0:
		state_machine.on_state_change("Walk")
		return
	
	if actor.jump_buffer_timer > 0:
		actor.jump_buffer_timer = 0
		state_machine.on_state_change("Jump")
		return
		
	if !actor.is_on_floor():
		state_machine.on_state_change("Fall")
		return
	else:
		if Input.is_action_pressed("crouch"):
			state_machine.on_state_change("Crouch")
			return

	actor.velocity.x = move_toward(actor.velocity.x, 0, actor.FRICTION * delta)
	actor.move_and_slide()

	if !actor.torso_animator.is_playing() or actor.torso_animator.animation != "Land":
		state_machine.on_state_change("Idle")
		
func on_exit_state():
	actor.set_hurtbox_size("Stand")
