extends CharacterBody2D
class_name CharacterBlueprint


var input_prefix := "player_one_"

# MAIN LOOP FUNCTIONS


func _ready() -> void:
	pass


func _get_local_input() -> Dictionary:
	var input_vector := Input.get_vector(input_prefix + "left", input_prefix + "right", input_prefix + "up", input_prefix + "down")
	var input : Dictionary
	
	if input_vector != Vector2.ZERO:
		input["input_vector"] = input_vector
	
	return input


func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input : Dictionary
	#input = previous_input.duplicate()
	#input.erase("input")
	return input


func _network_process(input : Dictionary) -> void: # _process and _physics_process replacement
	position += input.get("input_vector", Vector2.ZERO) * 8


func _save_state() -> Dictionary:
	return {
		position = position
	}


func _load_state(state: Dictionary) -> void:
	position = state["position"]


func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	position = lerp(old_state["position"], new_state["position"], weight)


# CLASS FUNCTIONS
