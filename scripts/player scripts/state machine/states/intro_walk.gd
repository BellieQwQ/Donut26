extends State

var intro_time = 5.0
var intro_timer = 0.0

var intro_direction = 1

func on_enter_state():
	intro_timer = intro_time
	
	actor.legs_animator.set_deferred("visible", true)
	actor.torso_animator.play("Run_torso")
	actor.legs_animator.play("Run_legs")
	print("Entering state: " + str(state_machine.current_state))
	
	actor.velocity.x = actor.SPEED * intro_direction
	
func on_physics(delta):
	intro_time -= delta
	
	actor.move_and_slide()
	
	if intro_time <= 0:
		state_machine.on_state_change("Idle")
	
func on_exit_state():
	actor.set_hurtbox_size("Stand")
	actor.legs_animator.set_deferred("visible", false)
