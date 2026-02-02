extends State


func on_enter_state():
	actor.camera.screen_shake(4, 0.1)
	actor.torso_animator.play("Roll")
	print("Entering state: " + str(state_machine.current_state))
	
	actor.evasion_direction = -1 if actor.isFacingRight else 1
	actor.velocity.x = actor.evasion_direction * (actor.BOUNCE_HORIZONTAL_BOOST - 120)
		
	actor.velocity.y = -(actor.BOUNCE_VERTICAL_BOOST - 120)
	
	actor.torso_animator.speed_scale = 1.6
	actor.torso_animator.scale = Vector2(1.5, 0.8) 
	
	actor.set_hurtbox_size("Evasion")
	actor.set_collision_size("Evasion")
	
func on_physics(_delta):
	
	if Input.is_action_just_pressed("evasion"):
		state_machine.on_state_change("Dive")
		return
	
	actor.move_and_slide()
	
	if actor.is_on_floor():
		state_machine.on_state_change("Land")
	
func on_exit_state():
	actor.torso_animator.speed_scale = 1.0 
	actor.torso_animator.skew = 0
	
	actor.set_hurtbox_size("Stand")
	actor.set_collision_size("Stand")
