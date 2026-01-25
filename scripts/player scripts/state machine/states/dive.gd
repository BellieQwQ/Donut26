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
	
	actor.stand_collision.set_deferred("disabled", true)
	actor.jump_collision.set_deferred("disabled", false)
	
func on_physics(delta):
	
	dive_timer -= delta
	
	actor.velocity.x = move_toward(actor.velocity.x, 0, actor.SKID_FRICTION * delta)
	
	if actor.velocity.y > 0:
		actor.stand_collision.set_deferred("disabled", false)
		actor.jump_collision.set_deferred("disabled", true)
	
	if dive_timer <= 0:
		actor.torso_animator.scale = Vector2(1, 1)
		
		if actor.is_on_floor():
			state_machine.on_state_change("Land")
	
	if actor.is_on_floor():
		state_machine.on_state_change("Land")
	
	actor.move_and_slide()
	
