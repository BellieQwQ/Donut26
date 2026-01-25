extends State

var not_falling_after_jump = false

func on_enter_state():
	
	not_falling_after_jump = (actor.coyote_timer > 0 and actor.jump_count == 0)

	if actor.jump_count == 2:
		actor.torso_animator.play("Roll")
	else:
		actor.torso_animator.play("Fall")

	print("Entering state: " + str(state_machine.current_state))

func on_physics(delta):
	if not_falling_after_jump and actor.coyote_timer <= 0 and actor.jump_count == 0:
		actor.jump_count = actor.max_jumps
		not_falling_after_jump = false
	
	if Input.is_action_just_pressed("jump"):
		if actor.coyote_timer > 0 or actor.jump_count < actor.max_jumps:
			state_machine.on_state_change("Jump")

	if Input.is_action_just_pressed("evasion"):
		state_machine.on_state_change("Dive")

	var air_speed = (actor.SPRINT_SPEED if actor.isSprinting else actor.SPEED) * 0.75
	var target_speed = air_speed * actor.direction

	if actor.direction != 0:
		var air_smoothness = clamp(actor.AIR_FRICTION * delta, 0.0, 1.0)
		actor.velocity.x = lerp(actor.velocity.x, target_speed, air_smoothness)
	else:
		var fall_smoothness = clamp(actor.AIR_DRAG * delta, 0.0, 1.0)
		actor.velocity.x = lerp(actor.velocity.x, 0.0, fall_smoothness)

	if actor.is_on_floor():
		if actor.jump_buffer_timer > 0:
			actor.jump_buffer_timer = 0
			state_machine.on_state_change("Jump")

		elif actor.direction != 0:
			actor.torso_animator.scale = Vector2(1.3, 0.7)
			state_machine.on_state_change("Walk")
		else:
			state_machine.on_state_change("Land")
	
	if Input.is_action_just_pressed("attack") and actor.jump_count >= 2:
		state_machine.on_state_change("RollAttack")
		return
	elif Input.is_action_just_pressed("attack") and actor.jump_count < 2:
		state_machine.on_state_change("Punch")
		return
	
	actor.move_and_slide()
