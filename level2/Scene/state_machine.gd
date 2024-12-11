extends Node

#@export var initial_state : State

#var current_state : State
#var states : Dictionary = {}

#func _ready() -> void:
#	if child is State:
#		states[child.name.to_lower()] = child
#		child.Transitioned.connected.connect(on_child_transition)


#func _process(delta: float) -> void:
#	if current_state:
#		current_state.Update(delta)
	
#func _physics_process(delta: float) -> void:
#	if current_state:
#		current_state.Physics_Update(delta)


#func on_child_transition(state, new_state_name):
#	if state != current_state:
#		return
		
#	var new_state = states.get(new_state_name.to_lower())
#	if current_state:
#		current_state.exit()
		
#	new_state.enter()
	
#	current_state = new_state
