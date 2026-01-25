extends State

var roll_duration = 0.35
var roll_timer = 0

func on_enter_state():
	actor.torso_animator.play("Roll")
	actor.torso_animator.speed_scale = 1.6
	
	actor.torso_animator.scale = Vector2(1.3, 0.7)
	actor.torso_animator.skew = 0.1
	
	if actor.direction != 0:
		actor.evasion_direction = sign(actor.direction)
	else:
		actor.evasion_direction = 1 if actor.isFacingRight else -1
	
	actor.velocity.x = actor.evasion_direction * actor.DIVE_HORIZONTAL_VELOCITY
	
	roll_timer = roll_duration
	
	print("Entering state: " + str(state_machine.current_state))
	
	actor.stand_collision.set_deferred("disabled", true)
	actor.evasion_collision.set_deferred("disabled", false)
	actor.evasion_detector.set_deferred("enabled", true)
	
func on_physics(delta):
	
	roll_timer -= delta
	
	actor.velocity.x = move_toward(actor.velocity.x, 0, actor.FRICTION * delta)
	
	if roll_timer <= 0:
		actor.torso_animator.scale = Vector2(1, 1)
		
		if actor.direction != 0 and !actor.blocked_above:
			if actor.isSprinting:
				state_machine.on_state_change("Sprint")
			else:
				state_machine.on_state_change("Walk")
		else:
			if Input.is_action_pressed("crouch") or actor.blocked_above:
				state_machine.on_state_change("Crouch")
			elif !actor.blocked_above:
				state_machine.on_state_change("Idle")
	
	actor.move_and_slide()
	
func on_exit_state():
	actor.torso_animator.speed_scale = 1.0
	actor.torso_animator.skew = 0
	
	actor.stand_collision.set_deferred("disabled", false)
	actor.evasion_collision.set_deferred("disabled", true)
	actor.evasion_detector.set_deferred("enabled", false)
