extends State

func on_enter_state():
	PointManager.update_points(actor.points)
	
	if actor.player:
		actor.player.perform_hitstop(0.04, 0.25)
	
	if actor.player_on_left:
		actor.animator.play("Death_left")
		actor.animator.skew = 0.2
	else:
		actor.animator.play("Death_right")
		actor.animator.skew = -0.2
	
	actor.hurtbox.set_deferred("monitorable", false)
	actor.collision.set_deferred("disabled", true)
	
	wait_and_revive()

func wait_and_revive():
	await actor.get_tree().create_timer(2.0).timeout
	state_machine.on_state_change("Revive")

func on_exit_state():
	actor.hurtbox.set_deferred("monitorable", true)
	actor.collision.set_deferred("disabled", false)
