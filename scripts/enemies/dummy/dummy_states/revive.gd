extends State

var revive_duration := 0.8
var revive_timer := 0.0

func on_enter_state():
	revive_timer = revive_duration
	actor.animator.play("Revive")
	actor.animator.scale = Vector2(0.6, 1.4)
	actor.health_points = 100
	
func on_physics(delta):
	
	revive_timer -= delta
	if revive_timer <= 0:
		state_machine.on_state_change("Idle")
		return
	
func on_exit_state():
	actor.animator.scale = Vector2(1, 1)
