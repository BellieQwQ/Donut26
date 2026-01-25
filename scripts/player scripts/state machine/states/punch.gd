extends State

var punch_duration = 0.25
var punch_timer = 0

func on_enter_state():
	punch_timer = punch_duration
	actor.legs_animator.set_deferred("visible", true)
	
	actor.punch_count += 1
	
	match actor.punch_count:
		1:
			actor.torso_animator.play("Punch_left_torso")
			actor.torso_animator.scale = Vector2(1.3, 0.8)
			actor.legs_animator.scale = Vector2(1.3, 1)
			if actor.is_on_floor():
				if actor.direction == 0:
					actor.legs_animator.play("Idle_punch_legs")
				else:
					actor.legs_animator.play("Idle_punch_legs")
			else:
				if actor.velocity.y < 0:
					actor.legs_animator.play("Jump_punch_legs")
				else:
					actor.legs_animator.play("Fall_legs")
		2:
			actor.torso_animator.play("Punch_right_torso")
			actor.torso_animator.scale = Vector2(1.3, 0.8)
			actor.legs_animator.scale = Vector2(1.3, 1)
			if actor.is_on_floor():
				actor.legs_animator.play("Idle_punch_legs")
			else:
				if actor.velocity.y < 0:
					actor.legs_animator.play("Jump_punch_legs")
				else:
					actor.legs_animator.play("Fall_legs")
		3:
			actor.torso_animator.play("Uppercut")
			actor.torso_animator.scale = Vector2(1.5, 0.8)
			actor.legs_animator.scale = Vector2(1.5, 1)
			actor.legs_animator.set_deferred("visible", false)
	
	actor.punch_area.set_deferred("monitoring", true)
	
	if actor.punch_count >= actor.max_punch:
		actor.punch_count = 0
	
	if actor.direction != 0:
		actor.punch_direction = sign(actor.direction)
	else:
		actor.punch_direction = 1 if actor.isFacingRight else -1
	
	print("Entering state: " + str(state_machine.current_state))
	
	
func on_physics(delta):
	if actor.jump_buffer_timer > 0 and actor.is_on_floor():
		actor.jump_buffer_timer = 0 
		state_machine.on_state_change("Jump")
		return
	
	punch_timer -= delta
	
	var base_speed = actor.SPRINT_SPEED if actor.isSprinting else actor.SPEED
	var target_velocity_x = base_speed * actor.direction
	
	actor.velocity.x = move_toward(actor.velocity.x, target_velocity_x, actor.ACCELERATION * delta)
	actor.move_and_slide()
	
	if punch_timer <= 0:
		if actor.is_on_floor():
			if actor.direction != 0:
				if actor.isSprinting:
					state_machine.on_state_change("Sprint")
				else:
					state_machine.on_state_change("Walk")
			else:
				state_machine.on_state_change("Idle")
		else:
			state_machine.on_state_change("Fall")
		return
	
func on_exit_state():
	actor.legs_animator.set_deferred("visible", false)
	actor.punch_area.set_deferred("monitoring", false)
