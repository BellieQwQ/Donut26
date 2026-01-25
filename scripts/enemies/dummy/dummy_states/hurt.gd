extends State

var hurt_duration := 0.2
var hurt_timer := 0.0

func on_enter_state():
	hurt_timer = hurt_duration
	
	if actor.player_on_left:
		actor.animator.play("Hurt_left")
		actor.animator.skew = 0.2
	else:
		actor.animator.play("Hurt_right")
		actor.animator.skew = -0.2
	
	actor.FXmanager.play("Hurt")
	actor.animator.scale = Vector2(0.8, 1.2)

func on_physics(delta):
	
	hurt_timer -= delta
	if hurt_timer <= 0:
		state_machine.on_state_change("Idle")
		return
	
func on_exit_state():
	actor.animator.scale = Vector2(1, 1)
	actor.animator.skew = 0
