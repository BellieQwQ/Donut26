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
	
	actor.roll_bounce_detector.set_deferred("enabled", true)
	
	actor.velocity.y = actor.ROLL_ATTACK_VERTICAL_BOOST 
	actor.roll_area.set_deferred("monitoring", true)
	
	print("Entering state: " + str(state_machine.current_state))
	
	actor.set_hurtbox_size("Evasion")
	actor.set_collision_size("Evasion")
	
func on_physics(_delta):
	
	actor.move_and_slide() 
	
	if actor.must_roll_bounce:
		state_machine.on_state_change("RollBounce") 
		actor.camera.screen_shake(4, 0.1)
		return 
	
func on_exit_state():
	actor.roll_area.set_deferred("monitoring", false)
	actor.roll_bounce_detector.set_deferred("enabled", false)
	actor.torso_animator.speed_scale = 1.0 
	
	actor.set_hurtbox_size("Stand")
	actor.set_collision_size("Stand")
