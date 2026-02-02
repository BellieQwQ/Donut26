extends State

var knockback_direction = 0

func on_enter_state():
	actor.invincible_timer = actor.invincible_time
	actor.is_invincible = true
	actor.torso_animator.play("Hurt")
	
	actor.hurtbox_area.set_deferred("monitoring", false)
	
	actor.torso_animator.scale = Vector2(0.8, 1.2) 
	
	if actor.emitter_on_left:
		knockback_direction = 1
	else:
		knockback_direction = -1
	
	actor.velocity.x = actor.KNOCKBACK_HORIZONTAL_FORCE * knockback_direction
	actor.velocity.y = -actor.KNOCKBACK_VERTICAL_FORCE
	
	print("Entering state: " + str(state_machine.current_state))
	
	actor.set_hurtbox_size("Stand")
	actor.set_collision_size("Stand")
	
func on_physics(_delta):
	
	actor.move_and_slide()
	
	if actor.is_on_floor():
		state_machine.on_state_change("Land")
	
func on_exit_state():
	actor.set_hurtbox_size("Stand")
