extends Node2D

@onready var player_spawner = $PlayerSpawner
@onready var camera = $LevelCamera

@export var player_scene: PackedScene
@export var hud_scene: PackedScene

func _ready():
	var player = player_scene.instantiate()
	player.global_position = player_spawner.global_position
	add_child(player)
	camera.actor_to_follow = player

	if hud_scene:
		var hud = hud_scene.instantiate()
		add_child(hud)
		hud.set_player(player)
		
		TransitionManager.on_intro_finished.connect(hud.on_timer_start, CONNECT_ONE_SHOT)
