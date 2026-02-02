extends Node

var total_points = 0

signal on_points_added(point_amount)

func update_points(point_amount):
	total_points += point_amount
	on_points_added.emit(point_amount)
