extends CharacterBody2D

@export var health_points: float

@onready var animator = $AnimatedSprite2D
@onready var hurtbox = $Hurtbox
@onready var collision = $CollisionShape2D
@onready var FXmanager = $AnimationPlayer
@onready var state_machine = $StateMachine

var player: Player
var player_on_left = true

const SQUASH_SPEED = 0.5

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	hurtbox.deal_damage.connect(on_receive_damage)
	
func _physics_process(delta):
	enemy_squash_and_stretch_recovery(delta)
	
func enemy_squash_and_stretch_recovery(delta):
	if animator.scale != Vector2.ONE:
		animator.scale.x = move_toward(animator.scale.x, 1.0, SQUASH_SPEED * delta)
		animator.scale.y = move_toward(animator.scale.y, 1.0, SQUASH_SPEED * delta)
	elif animator.skew != 0.0:
		animator.skew = move_toward(animator.skew, 0.0, SQUASH_SPEED * delta)
	
func on_receive_damage(damage, punch_position):
	print(health_points)
	health_points -= damage
	
	if punch_position.x < global_position.x:
		player_on_left = true
	else:
		player_on_left = false
	
	if health_points <= 0:
		state_machine.on_state_change("Die")
		return
	
	state_machine.on_state_change("Hurt")
