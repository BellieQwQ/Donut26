extends AnimatedSprite2D

@onready var animator = $"."

func _ready():
	animator.play("punch")

func _on_animation_finished():
	queue_free()
