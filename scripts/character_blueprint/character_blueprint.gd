extends CharacterBody2D
class_name CharacterBlueprint

@export var animation_player : NetworkAnimationPlayer

# ENUMS

enum state {
	STANDING_MOVEMENT, CROUCHING, ATTACKING, BLOCKING, HIT
}

# VARIABLES

var input_prefix := "player_one_"
var current_state : state
var previous_state : state

# STATE FUNCTIONS

func _standing_movement_state(directional_input: Vector2, input: Dictionary) -> void:
	position.x += directional_input.x * 2
	
	if directional_input.x > 0:
		animation_player.play("Walk Forward")
	elif directional_input.x < 0:
		animation_player.play("Walk Backward")
	else:
		animation_player.play("Idle")
	
	if directional_input.y > 0:
		animation_player.play("Crouch")
		_switch_state(state.CROUCHING)
	
	if input.get("light", false):
		animation_player.play("Standing Light")
		_switch_state(state.ATTACKING)
	
	if input.get("medium", false):
		animation_player.play("Standing Medium")
		_switch_state(state.ATTACKING)


func _crouching_state(directional_input: Vector2, input: Dictionary) -> void:
	if directional_input.y == 0:
		animation_player.play_backwards("Crouch")
		_switch_state(state.STANDING_MOVEMENT)
	
	if input.get("medium", false):
		animation_player.play("Crouching Medium")
		_switch_state(state.ATTACKING)


func _attacking_state(directional_input: Vector2, input: Dictionary) -> void:
	if animation_player.current_animation_position == animation_player.get_section_end_time():
		_switch_state(previous_state)


func _blocking_state(directional_input: Vector2, input: Dictionary) -> void:
	pass


func _switch_state(new_state: state) -> void:
	previous_state = current_state
	current_state = new_state


func _handle_current_state(directional_input: Vector2, input: Dictionary) -> void:
	match current_state:
		state.STANDING_MOVEMENT:
			_standing_movement_state(directional_input, input)
		state.CROUCHING:
			_crouching_state(directional_input, input)
		state.ATTACKING:
			_attacking_state(directional_input, input)
		state.BLOCKING:
			_blocking_state(directional_input, input)

# MAIN LOOP FUNCTIONS


func _ready() -> void:
	previous_state = state.STANDING_MOVEMENT
	current_state = state.STANDING_MOVEMENT


func _get_local_input() -> Dictionary:
	var directional_input_vector := Input.get_vector(input_prefix + "left", input_prefix + "right", input_prefix + "up", input_prefix + "down")
	var input : Dictionary
	
	if directional_input_vector != Vector2.ZERO:
		input["directional_input_vector"] = directional_input_vector
	if Input.is_action_just_pressed(input_prefix + "light"):
		input["light"] = true
	if Input.is_action_just_pressed(input_prefix + "medium"):
		input["medium"] = true
	
	return input


func _predict_remote_input(previous_input: Dictionary, ticks_since_real_input: int) -> Dictionary:
	var input := previous_input.duplicate()
	input.erase("light")
	input.erase("medium")
	return input


func _network_process(input : Dictionary) -> void: # _process and _physics_process replacement
	var directional_input_vector : Vector2 = input.get("directional_input_vector", Vector2.ZERO)
	
	_handle_current_state(directional_input_vector, input)
		
	move_and_slide()


func _save_state() -> Dictionary:
	return {
		"position" : position
	}


func _load_state(state: Dictionary) -> void:
	position = state["position"]


func _interpolate_state(old_state: Dictionary, new_state: Dictionary, weight: float) -> void:
	position = lerp(old_state["position"], new_state["position"], weight)



# CLASS FUNCTIONS
