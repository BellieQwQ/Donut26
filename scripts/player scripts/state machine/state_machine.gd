extends Node
class_name StateMachine

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.actor = self.get_parent()
	
	if initial_state:
		call_deferred("on_state_change", initial_state.name.to_lower())
		
func _process(delta):
	if current_state: 
		current_state.on_process(delta)
	
func _physics_process(delta):
	if current_state:
		current_state.on_physics(delta)
	
func _input(event):
	if current_state:
		current_state.on_input(event)
	
func on_state_change(new_state: String):
	if current_state:
		current_state.on_exit_state()
	
	current_state = states.get(new_state.to_lower())
	
	if current_state:
		current_state.on_enter_state()
