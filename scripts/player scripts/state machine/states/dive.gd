extends State

var dive_duration = 0.3
var dive_timer = 0

func on_enter_state():
	actor.torso_animator.play("Dive")
	
	actor.torso_animator.scale = Vector2(1.3, 0.7)
	
	if actor.direction != 0:
		actor.evasion_direction = sign(actor.direction)
	else:
		actor.evasion_direction = 1 if actor.isFacingRight else -1
	
	actor.velocity.y = -actor.DIVE_VERTICAL_VELOCITY
	actor.velocity.x = actor.evasion_direction * (actor.DIVE_HORIZONTAL_VELOCITY - 50)
	
	dive_timer = dive_duration
	
	print("Entering state: " + str(state_machine.current_state))
	
	actor.set_hurtbox_size("Dive")
	actor.set_collision_size("Stand")
	
func on_physics(delta):
	if Input.is_action_just_pressed("attack") and actor.jump_count >= 2:
		state_machine.on_state_change("RollAttack")
		return
	
	dive_timer -= delta
	
	actor.velocity.x = move_toward(actor.velocity.x, 0, actor.SKID_FRICTION * delta)
	
	if dive_timer <= 0:
		actor.torso_animator.scale = Vector2(1, 1)
		
		if actor.is_on_floor():
			state_machine.on_state_change("Land")
	
	if actor.is_on_floor():
		state_machine.on_state_change("Land")
	
	actor.move_and_slide()
	
func on_exit_state():
	actor.set_hurtbox_size("Stand")
	actor.set_collision_size("Stand")
	
