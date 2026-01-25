extends State

func on_enter_state():
	actor.jump_count = 0 
	
	actor.legs_animator.set_deferred("visible", true)
	
	actor.torso_animator.play("Idle_torso")
	actor.legs_animator.play("Idle_legs")
	print("Entering state: " + str(state_machine.current_state))
	
func on_physics(delta):
	if Input.is_action_just_pressed("attack"):
		state_machine.on_state_change("Punch")
		return
	
	if actor.jump_buffer_timer > 0 and actor.is_on_floor():
		actor.jump_buffer_timer = 0 
		state_machine.on_state_change("Jump")
		return
	
	if actor.velocity.y >= 0 and !actor.is_on_floor():
		state_machine.on_state_change("Fall")
		return
	
	if Input.is_action_pressed("crouch"):
		state_machine.on_state_change("Crouch")
		return
	
	if actor.is_on_floor():
		actor.velocity.x = move_toward(actor.velocity.x, 0, actor.FRICTION * delta)
	
	if actor.direction != 0:
		if actor.isSprinting:
			state_machine.on_state_change("Sprint")
		else:
			state_machine.on_state_change("Walk")
	
	actor.move_and_slide()

func on_exit_state():
	actor.legs_animator.set_deferred("visible", false)
