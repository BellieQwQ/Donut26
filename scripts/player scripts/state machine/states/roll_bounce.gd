extends State

var roll_attack_cooldown_time = 0.30
var roll_attack_cooldown_timer = 0

func on_enter_state():
	roll_attack_cooldown_timer = roll_attack_cooldown_time
	
	actor.torso_animator.play("Roll")
	print("Entering state: " + str(state_machine.current_state))
	
	if actor.velocity.x != 0: 
		actor.punch_direction = sign(actor.direction) 
		actor.velocity.x = actor.punch_direction * actor.BOUNCE_HORIZONTAL_BOOST
	else: 
		actor.punch_direction = 1 if actor.isFacingRight else -1 
		actor.velocity.x = 0
		
	actor.velocity.y = -actor.BOUNCE_VERTICAL_BOOST
	
	actor.torso_animator.speed_scale = 1.6
	actor.torso_animator.scale = Vector2(1.5, 0.8) 
	
	actor.set_hurtbox_size("Evasion")
	actor.set_collision_size("Evasion")
	
func on_physics(delta):
	roll_attack_cooldown_timer -= delta
	
	if Input.is_action_just_pressed("evasion"):
		state_machine.on_state_change("Dive")
		return
	
	actor.move_and_slide()
	
	var air_speed = actor.SPRINT_SPEED * 0.75
	var target_speed = air_speed * actor.direction
	
	if actor.direction != 0:
		var air_smoothness = clamp(actor.AIR_FRICTION * delta, 0.0, 1.0)
		actor.velocity.x = lerp(actor.velocity.x, target_speed, air_smoothness)
	else:
		var fall_smoothness = clamp(actor.AIR_DRAG * delta, 0.0, 1.0)
		actor.velocity.x = lerp(actor.velocity.x, 0.0, fall_smoothness)
		
	if Input.is_action_just_pressed("attack") and actor.can_chain_roll and roll_attack_cooldown_timer <= 0:
		actor.can_chain_roll = false
		state_machine.on_state_change("RollAttack")
	
	if actor.is_on_floor():
		state_machine.on_state_change("Land")
	
func on_exit_state():
	actor.torso_animator.speed_scale = 1.0 
	actor.torso_animator.skew = 0
	
	actor.set_hurtbox_size("Stand")
	actor.set_collision_size("Stand")
