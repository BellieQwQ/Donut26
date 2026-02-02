extends CanvasLayer

@onready var FXmanager = $Layout/AnimationPlayer

func open():
	FXmanager.play("Open")
	await FXmanager.animation_finished
