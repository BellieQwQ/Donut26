extends Node

@onready var bars_scene: PackedScene = preload("res://scenes/transitions/bars_transition.tscn")
@onready var iris_scene: PackedScene = preload("res://scenes/transitions/iris_transition.tscn")

var bars
var iris

signal on_intro_finished

func perfom_overworld_to_level(level_scene):
	iris = iris_scene.instantiate()
	get_tree().root.add_child(iris)
	
	iris.close()
	await iris.on_closed_iris
	
	get_tree().change_scene_to_packed(level_scene)
	await get_tree().process_frame
	iris.queue_free()
	
	bars = bars_scene.instantiate()
	get_tree().root.add_child(bars)
	
	await bars.open()
	emit_signal("on_intro_finished")
	bars.queue_free()
	
	
	
	
