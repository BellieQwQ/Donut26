extends Node2D

@onready var player_spawner = $PlayerSpawner
@onready var camera = $LevelCamera

@onready var opening_bars: PackedScene = preload("res://scenes/transitions/bars_transition.tscn")
@export var player_scene: PackedScene

func _ready():
	var player = player_scene.instantiate()
	player.global_position = player_spawner.global_position
	add_child(player)

	camera.actor_to_follow = player
	
	var bars = opening_bars.instantiate()
	add_child(bars)
	await bars.open()
