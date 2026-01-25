extends CharacterBody2D
class_name Overworld_Player

@onready var animator = $AnimatedSprite2D

func _ready() -> void:
	animator.play("down")
