extends Node2D

@onready var player: Overworld_Player = $playerOverworld
@onready var waypoints = $Waypoints

var current_waypoint: String = "A1"
var levels = {
	"A1": {
		"marker": "Waypoints/A1", 
		"neighbors": {"up": "A2"},
		"is_playable": true
	},
	"A2": {
		"marker": "Waypoints/A2",
		"neighbors": {"down": "A1", "right": "B1"},
		"is_playable": true
	},
	"B1": {
		"marker": "Waypoints/B1",
		"neighbors": {"left": "A2", "up": "A3"},
		"is_playable": false 
	},
	"A3": {
		"marker": "Waypoints/A3",
		"neighbors": {"down": "B1", "up": "B2"},
		"is_playable": true
	},
	"B2": {
		"marker": "Waypoints/B2",
		"neighbors": {"down": "A3", "left": "A4"},
		"is_playable": false
	},
	"A4": {
		"marker": "Waypoints/A4",
		"neighbors": {"right": "B2", "up": "A5", "left": "A6"},
		"is_playable": true
	},
	"A5": {
		"marker": "Waypoints/A5",
		"neighbors": {"down": "A4"},
		"is_playable": true
	},
	"A6": {
		"marker": "Waypoints/A6",
		"neighbors": {"right": "A4"},
		"is_playable": true
	},
}

var is_moving = false

func _ready():
	var marker_path = levels[current_waypoint]["marker"]
	var start_position = get_node(marker_path)
	
	player.global_position = start_position.global_position

func _unhandled_input(_event):
	if is_moving:
		return
	
	var neighbors = levels[current_waypoint]["neighbors"]
	
	if Input.is_action_just_pressed("jump") and neighbors.has("up"):
		player.animator.play("up")
		move_towards_level(neighbors["up"], current_waypoint)
			
	elif Input.is_action_just_pressed("crouch") and neighbors.has("down"):
		player.animator.play("down")
		move_towards_level(neighbors["down"], current_waypoint)
			
	elif Input.is_action_just_pressed("right") and neighbors.has("right"):
		player.animator.play("right")
		move_towards_level(neighbors["right"], current_waypoint)
			
	elif Input.is_action_just_pressed("left") and neighbors.has("left"):
		player.animator.play("left")
		move_towards_level(neighbors["left"], current_waypoint)

func move_towards_level(target_level, from_level):
	is_moving = true
	
	var level_data = levels[target_level]
	var target_waypoint = get_node(level_data["marker"])
	
	var move_tween = create_tween()
	move_tween.tween_property(player, "global_position", target_waypoint.global_position, 0.8)
	
	move_tween.finished.connect(func():
		current_waypoint = target_level
		
		if not level_data["is_playable"]:
			continue_movement(from_level)
		else:
			is_moving = false
			player.animator.play("down")
	)
	
func continue_movement(last_level):
	var neighbors = levels[current_waypoint]["neighbors"]
	
	for direction in neighbors:
		var next_node = neighbors[direction]
		
		if next_node != last_level:
			player.animator.play(direction)
			move_towards_level(next_node, current_waypoint)
			return
