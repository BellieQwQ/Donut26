extends State

var just_entered: bool

func on_enter_state():
	just_entered = true
	actor.jump_count += 1
	actor.coyote_timer = 0.0

	actor.torso_animator.play("Roll")
	actor.torso_animator.scale = Vector2(0.8, 1.2)

	actor.velocity.y = actor.jump_velocity
	print("Entering state: " + str(state_machine.current_state))

	actor.set_collision_size("Jump")

func on_physics(delta):
	if just_entered:
		just_entered = false
		return
	
	if Input.is_action_just_pressed("evasion"):
		state_machine.on_state_change("Dive")
		return

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
		return

	if Input.is_action_just_pressed("attack"):
		state_machine.on_state_change("RollAttack")
		return

	actor.move_and_slide()

func on_exit_state():
	just_entered = false
