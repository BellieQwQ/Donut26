extends AnimatedSprite2D

@onready var FXmanager = $AnimationPlayer

func show_point_popup(point_amount):
	play(str(point_amount))
	FXmanager.play("popup")
	
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "popup":
		queue_free()
