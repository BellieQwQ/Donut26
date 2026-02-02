extends CharacterBody2D
class_name Player

signal update_lives(current_lives)

const SPEED = 110              
const SPRINT_SPEED = 230       
const ACCELERATION = 780       
const FRICTION = 1300 
const SKID_FRICTION = 600  
 
const AIR_FRICTION = 10.0      
const AIR_DRAG = 1.0  
const MAX_FALL_SPEED = 400     

const DIVE_HORIZONTAL_VELOCITY = 450  
const DIVE_VERTICAL_VELOCITY = 100  
  
const ROLL_ATTACK_HORIZONTAL_BOOST = 150  
const ROLL_ATTACK_VERTICAL_BOOST = 200  
 
const BOUNCE_HORIZONTAL_BOOST = 200       
const BOUNCE_VERTICAL_BOOST = 300  

const KNOCKBACK_HORIZONTAL_FORCE = 150
const KNOCKBACK_VERTICAL_FORCE = 150

const SQUASH_SPEED = 2         

const PUNCH_DAMAGE = 25.0
const ROLL_DAMAGE = 40.0
const SLIDE_DAMAGE = 30.0

var lives = 3

var coyote_time = 0.13
var coyote_timer = 0

var jump_buffer_time: float = 0.1  
var jump_buffer_timer: float = 0.0

var jump_height = 90 
var time_to_peak = 0.5 
var time_to_descent = 0.4 

var jump_velocity = ((2.0 * jump_height) / (time_to_peak)) * -1
var double_jump_velocity = ((2.0 * jump_height) / (time_to_peak)) * -1
var jump_gravity = ((-2.0 * jump_height) / (time_to_peak * time_to_peak)) * -1 * 1.2
var fall_gravity = ((-2.0 * jump_height) / (time_to_descent * time_to_descent)) * -1 * 1.4

var was_on_floor = false
var isFacingRight = true
var isSprinting = false
var blocked_above = false
var must_roll_bounce = false
var must_bounce = false
var can_chain_roll = false
var is_sliding = false
var is_invincible = false
var is_in_intro = false

var direction = 0
var evasion_direction = 0
var punch_direction = 0

var invincible_time = 0.8
var invincible_timer = 0

var max_jumps = 2
var jump_count = 0

var max_punch = 3
var punch_count = 0

var roll_attack_combo_counter = 0
var slide_attack_combo_counter = 0

var enemies_hit_by_slide = []
var emitter_on_left = false

var camera: Camera2D
@export var punch_particles_scene: PackedScene

@onready var state_machine = $StateMachine
@onready var FXmanager = $FXmanager

#Animators
@onready var torso_animator = $torso
@onready var legs_animator = $legs

#Collisions
@onready var collision = $Collision

#Detectors
@onready var bounce_detector = $BounceDetector
@onready var evasion_detector = $EvasionDetector
@onready var roll_bounce_detector = $RollBounceDetector

#Hitboxes
@onready var punch_area = $Punch_hitbox
@onready var roll_area = $Roll_hitbox
@onready var slide_area = $Slide_hitbox

#Hurtbox
@onready var hurtbox_area = $Hurtbox
@onready var hurtbox_shape = $Hurtbox/CollisionShape2D

#Spawners
@onready var punch_particle_spawner = $Punch_Particle_Spawner
@onready var roll_particle_spawner = $Roll_Particle_Spawner
@onready var slide_particle_spawner = $Slide_Particle_Spawner

func _ready():
	camera = get_tree().get_first_node_in_group("Camera") as Camera2D
	
	slide_area.area_entered.connect(on_emit_slide_damage)
	punch_area.area_entered.connect(on_emit_punch_damage)
	roll_area.area_entered.connect(on_emit_roll_damage)
	
	hurtbox_area.deal_damage.connect(on_receive_damage)

func _physics_process(delta):
	
	apply_gravity(delta)
	apply_coyote_time(delta)
	apply_jump_buffer(delta)
	apply_corner_correction()
	player_squash_and_stretch_recovery(delta)
	
	
	direction = Input.get_axis("left", "right")
	isSprinting = Input.is_action_pressed("sprint")
	
	if direction > 0 and !isFacingRight:
		flip()
	elif direction < 0 and isFacingRight:
		flip()
	
	blocked_above = evasion_detector.is_colliding()
	must_roll_bounce = roll_bounce_detector.is_colliding() 
	must_bounce = bounce_detector.is_colliding()
	
	if is_on_floor() and !was_on_floor:
		roll_attack_combo_counter = 0
	
	if !is_on_floor() or !is_sliding:
		slide_attack_combo_counter = 0
	
	was_on_floor = is_on_floor()
	
	if is_invincible:
		invincible_timer -= delta
		FXmanager.play("Iframes_0.8")
	
		if invincible_timer <= 0:
			is_invincible = false
	
func set_collision_size(collision_name):
	if collision_name == "Stand":
		collision.shape.size = Vector2(10.0, 19.0)
		collision.position = Vector2(0.0, 6.0)
	elif collision_name == "Evasion":
		collision.shape.size = Vector2(10.0, 10.0)
		collision.position = Vector2(0.0, 10.0)
	elif collision_name == "Jump":
		collision.shape.size = Vector2(10.0, 10.0)
		collision.position = Vector2(0.0, -4.0)
	else:
		print("invalid collision name")
	
func set_hurtbox_size(hurtbox_name):
	if hurtbox_name == "Stand":
		hurtbox_shape.shape.size = Vector2(14.0, 20.0)
		hurtbox_shape.position = Vector2(0.0, 6.0)
	elif hurtbox_name == "Evasion":
		hurtbox_shape.shape.size = Vector2(14.0, 13.0)
		hurtbox_shape.position = Vector2(0.0, 9.0)
	elif hurtbox_name == "Dive":
		hurtbox_shape.shape.size = Vector2(14.0, 13.0)
		hurtbox_shape.position = Vector2(0.0, -4.0)
	else:
		print("invalid hurtbox name")
	
func get_roll_combo_points():
	var combo_sequence = [100, 200, 500, 700, 1000, 1400, 1800, 2000]
	return combo_sequence[min(roll_attack_combo_counter, combo_sequence.size() - 1)]
	
func get_slide_combo_points():
	var combo_sequence = [100, 200, 500, 700, 1000, 1400, 1800, 2000]
	return combo_sequence[min(slide_attack_combo_counter, combo_sequence.size() - 1)]
	
func on_emit_punch_damage(area: Area2D):
	if !(area is Hurtbox):
		return
	
	var hurtbox = area as Hurtbox
	
	hurtbox.deal_damage.emit(PUNCH_DAMAGE, global_position)
	camera.screen_shake(6, 0.1)
	spawn_particles(punch_particle_spawner.global_position)
	
	var enemy = hurtbox.get_parent()

	if enemy.health_points <= 0:
		PointManager.update_points(enemy.points)
		enemy.spawn_point_popup(enemy.points)
	
func on_emit_roll_damage(area: Area2D):
	if !(area is Hurtbox):
		return
	
	var hurtbox = area as Hurtbox
	
	hurtbox.deal_damage.emit(ROLL_DAMAGE, global_position)
	camera.screen_shake(6, 0.1)
	spawn_particles(roll_particle_spawner.global_position)
	
	var enemy = hurtbox.get_parent() 
	
	if !is_on_floor() and enemy.health_points <= 0:
		var combo_points = get_roll_combo_points()
		roll_attack_combo_counter += 1
		PointManager.update_points(combo_points)
		enemy.spawn_point_popup(combo_points)
	
	can_chain_roll = true
	state_machine.on_state_change("RollBounce") 
	return 
	
func on_emit_slide_damage(area: Area2D):
	if !(area is Hurtbox):
		return
	
	var hurtbox = area as Hurtbox
	
	if hurtbox in enemies_hit_by_slide:
		return
	else:
		enemies_hit_by_slide.append(hurtbox)
	
	hurtbox.deal_damage.emit(SLIDE_DAMAGE, global_position)
	camera.screen_shake(6, 0.1)
	spawn_particles(slide_particle_spawner.global_position)
	
	var enemy = hurtbox.get_parent() 
	
	if is_on_floor() and enemy.health_points <= 0 and is_sliding:
		var combo_points = get_slide_combo_points()
		slide_attack_combo_counter += 1
		PointManager.update_points(combo_points)
		enemy.spawn_point_popup(combo_points)
	
	if enemy.health_points > 0:
		state_machine.on_state_change("Bounce")
	else:
		state_machine.on_state_change("Slide")
	
func on_receive_damage(damage, source_position):
	if is_invincible: 
		return
	
	if lives <= 0:
		return
	
	emitter_on_left = source_position.x < global_position.x
	
	lives -= damage
	update_lives.emit(lives)
	
	camera.screen_shake(8, 0.4)
	perform_hitstop(0.05, 0.2)
	state_machine.on_state_change("Hurt")
	
	print(lives)
	
func player_squash_and_stretch_recovery(delta):
	if torso_animator.scale != Vector2.ONE:
		torso_animator.scale.x = move_toward(torso_animator.scale.x, 1.0, SQUASH_SPEED * delta)
		torso_animator.scale.y = move_toward(torso_animator.scale.y, 1.0, SQUASH_SPEED * delta)
	
	if legs_animator.scale != Vector2.ONE:
		legs_animator.scale.x = move_toward(legs_animator.scale.x, 1.0, SQUASH_SPEED * delta)
		legs_animator.scale.y = move_toward(legs_animator.scale.y, 1.0, SQUASH_SPEED * delta)
	
func apply_jump_buffer(delta):
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
		
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
func apply_coyote_time(delta):
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
	
func apply_gravity(delta):
	if velocity.y < 0:
		velocity.y += jump_gravity * delta
	else:
		velocity.y += fall_gravity * delta
			
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED
	
func apply_corner_correction():
	var amount = 10
	var delta = get_physics_process_delta_time()
	
	if velocity.y < 0 and test_move(global_transform, Vector2(0, velocity.y * delta)):
		for i in range(1, amount + 1):
			for j in [-1.0, 1.0]:
				if !test_move(global_transform.translated(Vector2(i * j, 0)), Vector2(0, velocity.y * delta)):
					translate(Vector2(i * j, 0))
					return
	
func perform_hitstop(engine_velocity, duration):
	Engine.time_scale = engine_velocity
	await get_tree().create_timer(duration * engine_velocity).timeout
	Engine.time_scale = 1.0
	
func flip():
	if !is_in_intro:
		isFacingRight = !isFacingRight
		scale.x *= -1
	
func spawn_particles(particle_position):
	var particles = punch_particles_scene.instantiate()
	particles.global_position = particle_position
	get_tree().current_scene.add_child(particles)
