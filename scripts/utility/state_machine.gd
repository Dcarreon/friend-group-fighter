class_name StateMachine
extends Node

var current_state: State

func _change_state(new_state: State) -> void:
	if current_state != null:
		current_state._exit_state()
	current_state = new_state
	current_state._enter_state()
