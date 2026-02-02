extends CanvasLayer

@onready var lives_counter = $Layout/MarginContainer/HBoxContainer/Left/Lives
@onready var seconds_timer = $Layout/MarginContainer/HBoxContainer/Center/Timer

@onready var hundreds = $Layout/MarginContainer/HBoxContainer/Center/Hundreds
@onready var tens = $Layout/MarginContainer/HBoxContainer/Center/Tens
@onready var units = $Layout/MarginContainer/HBoxContainer/Center/Units

@onready var digit1 = $Layout/MarginContainer/HBoxContainer/Right/Digit1
@onready var digit2 = $Layout/MarginContainer/HBoxContainer/Right/Digit2
@onready var digit3 = $Layout/MarginContainer/HBoxContainer/Right/Digit3
@onready var digit4 = $Layout/MarginContainer/HBoxContainer/Right/Digit4
@onready var digit5 = $Layout/MarginContainer/HBoxContainer/Right/Digit5
@onready var digit6 = $Layout/MarginContainer/HBoxContainer/Right/Digit6

var total_time = 40

var player: Player

func _ready():
	update_timer_time()
	
	PointManager.on_points_added.connect(on_points_added)

func set_player(is_player):
	player = is_player

	if not player.update_lives.is_connected(on_lives_update):
		player.update_lives.connect(on_lives_update)

	on_lives_update(player.lives)

func on_lives_update(current_lives):
	current_lives = clamp(current_lives, 1, 3)
	lives_counter.play(str(current_lives))

func split_point_value(value):
	value = clamp(value, 0, 999999)
	return [
		(value / 100000) % 10,
		(value / 10000)  % 10,
		(value / 1000)   % 10,
		(value / 100)    % 10,
		(value / 10)     % 10,
		value % 10
	]

func update_point_counter(value):
	var digits = split_point_value(value)
	
	digit1.frame = digits[0]
	digit2.frame = digits[1]
	digit3.frame = digits[2]
	digit4.frame = digits[3]
	digit5.frame = digits[4]
	digit6.frame = digits[5]

func on_points_added(_amount):
	update_point_counter(PointManager.total_points)

func update_timer_time():
	var hundred = total_time / 100
	var ten = (total_time / 10) % 10
	var unit = total_time % 10

	hundreds.frame = hundred
	tens.frame = ten
	units.frame = unit
	
func on_timer_start():
	seconds_timer.start()

func _on_timer_timeout():
	
	total_time = max(total_time - 1, 0)
	update_timer_time()
	
	if total_time == 0:
		seconds_timer.stop()
		return
