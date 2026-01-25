extends CharacterBody2D
class_name Player



const SPEED = 110              
const SPRINT_SPEED = 230       
const ACCELERATION = 780       
const FRICTION = 1300          
const AIR_FRICTION = 10.0      
const AIR_DRAG = 1.0           
const SKID_FRICTION = 600      
const DIVE_HORIZONTAL_VELOCITY = 450  
const DIVE_VERTICAL_VELOCITY = 100    
const MAX_FALL_SPEED = 400     
const ROLL_ATTACK_HORIZONTAL_BOOST = 200  
const ROLL_ATTACK_VERTICAL_BOOST = 200    
const BOUNCE_HORIZONTAL_BOOST = 200       
const BOUNCE_VERTICAL_BOOST = 300         
const SQUASH_SPEED = 2         

const PUNCH_DAMAGE = 25.0
const ROLL_DAMAGE = 40.0

var coyote_time = 0.12
var coyote_timer = 0

var jump_buffer_time: float = 0.1  
var jump_buffer_timer: float = 0.0

var jump_height = 90 # TODO 70
var time_to_peak = 0.5 # TODO 0.45
var time_to_descent = 0.4 # TODO 0.38

var jump_velocity = ((2.0 * jump_height) / (time_to_peak)) * -1
var double_jump_velocity = ((2.0 * jump_height) / (time_to_peak)) * -1
var jump_gravity = ((-2.0 * jump_height) / (time_to_peak * time_to_peak)) * -1 * 1.2
var fall_gravity = ((-2.0 * jump_height) / (time_to_descent * time_to_descent)) * -1 * 1.4

var was_on_floor = false
var isFacingRight = true
var isSprinting = false
var blocked_above = false
var must_bounce = false
var can_chain_roll = false

var direction = 0
var evasion_direction = 0
var punch_direction = 0

var max_jumps = 2
var jump_count = 0

var max_punch = 3
var punch_count = 0

@export var punch_particles_scene: PackedScene

@onready var state_machine = $StateMachine
@onready var camera = $Camera2D
@onready var torso_animator = $torso
@onready var legs_animator = $legs
@onready var stand_collision = $"StandCollision"
@onready var jump_collision = $"JumpCollision"
@onready var evasion_collision = $"EvasionCollision"
@onready var evasion_detector = $EvasionDetector
@onready var bounce_detector = $RollBounceDetector
@onready var punch_area = $Punch_hitbox
@onready var roll_area = $Roll_hitbox
@onready var punch_particle_spawner = $Punch_Particle_Spawner
@onready var roll_particle_spawner = $Roll_Particle_Spawner

func _ready():
	punch_area.area_entered.connect(on_emit_punch_damage)
	roll_area.area_entered.connect(on_emit_roll_damage)

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
	must_bounce = bounce_detector.is_colliding()
	
	was_on_floor = is_on_floor()
	
func on_emit_punch_damage(hurtbox: Hurtbox):
	hurtbox.deal_damage.emit(PUNCH_DAMAGE, global_position)
	camera.screen_shake(2, 0.1)
	spawn_particles(punch_particle_spawner.global_position)
	
func on_emit_roll_damage(hurtbox: Hurtbox):
	hurtbox.deal_damage.emit(ROLL_DAMAGE, global_position)
	camera.screen_shake(4, 0.1)
	spawn_particles(roll_particle_spawner.global_position)
	can_chain_roll = true
	state_machine.on_state_change("Bounce") 
	return 
	
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
	isFacingRight = !isFacingRight
	scale.x *= -1
	
func spawn_particles(particle_position):
	var particles = punch_particles_scene.instantiate()
	particles.global_position = particle_position
	get_tree().current_scene.add_child(particles)
