extends State

func on_enter_state():
	actor.torso_animator.play("Roll") 
	actor.torso_animator.speed_scale = 1.6
	actor.torso_animator.scale = Vector2(0.5, 1.5) 
	
	if actor.direction != 0: 
		actor.punch_direction = sign(actor.direction) 
		actor.velocity.x = actor.punch_direction * actor.ROLL_ATTACK_HORIZONTAL_BOOST
		actor.torso_animator.skew = 0.2 
	else: 
		actor.punch_direction = 1 if actor.isFacingRight else -1 
		actor.velocity.x = 0
	
	actor.bounce_detector.set_deferred("enabled", true)
	
	actor.velocity.y = actor.ROLL_ATTACK_VERTICAL_BOOST 
	actor.roll_area.set_deferred("monitoring", true)
	
	print("Entering state: " + str(state_machine.current_state))
	
func on_physics(_delta):
	actor.move_and_slide() 
	
	if actor.bounce_detector.is_colliding():
		state_machine.on_state_change("Bounce") 
		actor.camera.screen_shake(4, 0.1)
		return 
	
func on_exit_state():
	actor.roll_area.set_deferred("monitoring", false)
	actor.bounce_detector.set_deferred("enabled", false)
	actor.torso_animator.speed_scale = 1.0 
