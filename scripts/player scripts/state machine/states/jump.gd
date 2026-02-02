extends State

func on_enter_state():
	actor.set_hurtbox_size("Stand")
	
	if actor.coyote_timer > 0:
		actor.jump_count = 1
		actor.coyote_timer = 0
	else:
		actor.jump_count += 1

	if actor.jump_count == 1:
		actor.torso_animator.play("Jump")
		actor.torso_animator.scale = Vector2(0.7, 1.3)
	else:
		actor.torso_animator.play("Roll")

	actor.velocity.y = actor.jump_velocity
	print("Entering state: " + str(state_machine.current_state))

	actor.set_collision_size("Jump")

func on_physics(delta):
	if Input.is_action_just_pressed("jump") and actor.jump_count < actor.max_jumps:
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

	if actor.velocity.y < 0 and !Input.is_action_pressed("jump"):
		actor.velocity.y *= 0.8

	if actor.velocity.y >= 0:
		state_machine.on_state_change("Fall")
	
	if Input.is_action_just_pressed("attack") and actor.jump_count >= 2:
		state_machine.on_state_change("RollAttack")
		return
	elif Input.is_action_just_pressed("attack") and actor.jump_count < 2:
		state_machine.on_state_change("Punch")
		return

	actor.move_and_slide()

func on_exit_state():
	actor.set_hurtbox_size("Stand")
