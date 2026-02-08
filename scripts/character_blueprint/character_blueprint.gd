class_name CharacterBlueprint
extends CharacterBody2D

# ENUMERATIONS ------------------------------------------------------

enum facing {
	RIGHT, LEFT
}

enum game_input {
	UP, DOWN, LEFT, RIGHT,
	UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT,
	LIGHT, MEDIUM, HEAVY, 
	UP_RELEASED, DOWN_RELEASED, LEFT_RELEASED, RIGHT_RELEASED,
	LIGHT_RELEASED, MEDIUM_RELEASED, HEAVY_RELEASED,
	NOINPUT
}

enum attack_type {
	LOW, MID, HIGH, GRAB
}

# VARIABLES ------------------------------------------------------

@export var pivot : Node2D
@export var physics_collision : Node2D

var input_queue_size : int = 4
var input_queue : Array[game_input]
var input_delay_timer : Timer

# SIGNALS ------------------------------------------------------

signal GameInputPressed(input : game_input, default_input : String)

# FUNCTIONS ------------------------------------------------------

func _flip_sprite() -> void:
	pivot.scale.x *= -1.0
	physics_collision.scale.x *= -1.0

func _facing_direction() -> facing:
	if pivot.scale.x < 0:
		return facing.LEFT
	return facing.RIGHT

func _new_timer(time : float, old_timer : Timer = null) -> Timer:
	if old_timer != null:
		old_timer.queue_free()
		old_timer = null
	
	var new_timer = Timer.new()
	new_timer.wait_time = time
	new_timer.one_shot = true
	add_child(new_timer)
	
	return new_timer

func _push_input_queue(input : game_input, default_input : String) -> void:
	input_queue.push_front(input)
	GameInputPressed.emit(input, default_input)
	
	if input_queue.size() > input_queue_size:
		input_queue.pop_back()

	print(default_input)

func _input(event: InputEvent) -> void:
	for action in InputMap.get_actions():
		if event.is_action_released(action):
			match action:
				"game_up":
					_push_input_queue(game_input.UP_RELEASED,"game_up_released")
				"game_down":
					_push_input_queue(game_input.DOWN_RELEASED,"game_down_released")
				"game_left":
					_push_input_queue(game_input.LEFT_RELEASED,"game_left_released")
				"game_right":
					_push_input_queue(game_input.RIGHT_RELEASED,"game_right_released")
				"game_light":
					_push_input_queue(game_input.LIGHT_RELEASED,"game_light_released")
				"game_medium":
					_push_input_queue(game_input.MEDIUM_RELEASED,"game_medium_released")
				"game_heavy":
					_push_input_queue(game_input.HEAVY_RELEASED,"game_heavy_released")

func _physics_process(delta: float) -> void:
	var directional_input_vector : Vector2 = Input.get_vector("game_left","game_right","game_up","game_down")

	if Input.is_action_just_pressed("game_light"):
		_push_input_queue(game_input.LIGHT,"game_light")

	if Input.is_action_just_pressed("game_medium"):
		_push_input_queue(game_input.MEDIUM,"game_medium")

	if Input.is_action_just_pressed("game_heavy"):
		_push_input_queue(game_input.HEAVY,"game_heavy")

	if directional_input_vector.x != 0 || directional_input_vector.y != 0:
		var sum_of_inputs : float = directional_input_vector.x + directional_input_vector.y

		if sum_of_inputs == 0: #either down_left or up_right
			if directional_input_vector.y < 0:
				_push_input_queue(game_input.UP_RIGHT,"game_up_right")
			else:
				_push_input_queue(game_input.DOWN_LEFT,"game_down_left")

		if sum_of_inputs > 0: #either down_right, down or right
			if sum_of_inputs > 1:
				_push_input_queue(game_input.DOWN_RIGHT,"game_down_right")
			elif directional_input_vector.y > 0:
				_push_input_queue(game_input.DOWN,"game_down")
			else:
				_push_input_queue(game_input.RIGHT,"game_right")

		if sum_of_inputs < 0: #either up_left, up or left
			if sum_of_inputs < -1:
				_push_input_queue(game_input.UP_LEFT,"game_up_left")
			elif directional_input_vector.y < 0:
				_push_input_queue(game_input.UP,"game_up")
			else:
				_push_input_queue(game_input.LEFT,"game_left")

# CLASSES ------------------------------------------------------

class SpecialInput:
	var player : CharacterBlueprint
	var input_list_right : Array[game_input]
	var input_list_left : Array[game_input]
	var input_stack : Array[game_input]
	var input_previous : game_input = game_input.NOINPUT
	var input_timer : Timer
	signal input_completed

	func _initialize(character: CharacterBlueprint) -> void:
		player = character
		player.GameInputPressed.connect(_input_detect)
		input_timer = player._new_timer(0.15)
		_reset_stack()

	func _reset_stack() -> void:
		input_stack.clear()

		if player._facing_direction() == facing.RIGHT:
			for input in input_list_right:
				input_stack.push_back(input)
		if player._facing_direction() == facing.LEFT:
			for input in input_list_left:
				input_stack.push_back(input)

	func _input_detect(event : game_input, default_input : String) -> void:
		input_timer.start()

		if !input_stack.is_empty() && !input_timer.is_stopped():
			if event == input_stack.front():
				input_stack.pop_front()
				input_timer.start()
				input_previous = event
				if input_stack.is_empty():
					input_completed.emit()
					_reset_stack()
					input_timer.stop()
			elif event == input_previous:
				pass
			else:
				input_previous = game_input.NOINPUT
				input_timer.stop()
				_reset_stack()
