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

# SIGNALS ------------------------------------------------------

signal GameInputPressed(input : game_input)
signal SpriteFlipped

# FUNCTIONS ------------------------------------------------------

func _flip_sprite() -> void:
	pivot.scale.x *= -1.0
	physics_collision.scale.x *= -1.0
	SpriteFlipped.emit()

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

func _push_input_queue(input : game_input) -> void:
	if not input_queue.is_empty():
		if input != input_queue.front():
			input_queue.push_front(input)
			GameInputPressed.emit(input)
	else:
		input_queue.push_front(input)

	if input_queue.size() > input_queue_size:
		input_queue.pop_back()

func _queue_directional_inputs(directional_input : Vector2) -> void:
	if directional_input.x != 0 || directional_input.y != 0:
		var sum_of_inputs : float = directional_input.x + directional_input.y

		if sum_of_inputs == 0: #either down_left or up_right
			if directional_input.y < 0:
				_push_input_queue(game_input.UP_RIGHT)
			else:
				_push_input_queue(game_input.DOWN_LEFT)

		if sum_of_inputs > 0: #either down_right, down or right
			if sum_of_inputs > 1:
				_push_input_queue(game_input.DOWN_RIGHT)
			elif directional_input.y > 0:
				_push_input_queue(game_input.DOWN)
			else:
				_push_input_queue(game_input.RIGHT)

		if sum_of_inputs < 0: #either up_left, up or left
			if sum_of_inputs < -1:
				_push_input_queue(game_input.UP_LEFT)
			elif directional_input.y < 0:
				_push_input_queue(game_input.UP)
			else:
				_push_input_queue(game_input.LEFT)

func _queue_input_release(event : InputEvent) -> void:
	for action in InputMap.get_actions():
		if event.is_action_released(action):
			match action:
				"game_up":
					_push_input_queue(game_input.UP_RELEASED)
				"game_down":
					_push_input_queue(game_input.DOWN_RELEASED)
				"game_left":
					_push_input_queue(game_input.LEFT_RELEASED)
				"game_right":
					_push_input_queue(game_input.RIGHT_RELEASED)
				"game_light":
					_push_input_queue(game_input.LIGHT_RELEASED)
				"game_medium":
					_push_input_queue(game_input.MEDIUM_RELEASED)
				"game_heavy":
					_push_input_queue(game_input.HEAVY_RELEASED)

func _input(event: InputEvent) -> void:
	_queue_input_release(event)

func _physics_process(delta: float) -> void:
	var directional_input : Vector2 = Input.get_vector("game_left","game_right","game_up","game_down")

	if Input.is_action_just_pressed("game_light"):
		_push_input_queue(game_input.LIGHT)

	if Input.is_action_just_pressed("game_medium"):
		_push_input_queue(game_input.MEDIUM)

	if Input.is_action_just_pressed("game_heavy"):
		_push_input_queue(game_input.HEAVY)

	_queue_directional_inputs(directional_input)

# CLASSES ------------------------------------------------------

class SpecialInput:
	var player : CharacterBlueprint
	var input_list_right : Array[game_input]
	var input_list_left : Array[game_input]
	var input_stack : Array[game_input]
	var input_timer : Timer
	var enabled : bool
	signal input_completed

	func _initialize(character: CharacterBlueprint, set_enabled : bool = true) -> void:
		player = character
		enabled = set_enabled
		player.GameInputPressed.connect(_match_first_input)
		player.SpriteFlipped.connect(_reset_stack)
		input_timer = player._new_timer(0.15)
		input_timer.timeout.connect(_reset_stack)
		_reset_stack()

	func _reset_stack() -> void:
		input_stack.clear()

		if player._facing_direction() == facing.RIGHT:
			for input in input_list_right:
				input_stack.push_back(input)
		if player._facing_direction() == facing.LEFT:
			for input in input_list_left:
				input_stack.push_back(input)

	func _match_first_input(event : game_input) -> void:
		if enabled:
			if not input_stack.is_empty() && input_timer.is_stopped():
				if event == input_stack.front():
					input_stack.pop_front()
					input_timer.start()
			else:
				_match_consecutive_inputs(event)

	func _match_consecutive_inputs(event : game_input) -> void:
		if not input_stack.is_empty() && not input_timer.is_stopped():
			if event == input_stack.front():
				input_stack.pop_front()
				input_timer.start()
				if input_stack.is_empty():
					input_completed.emit()
					_reset_stack()
					input_timer.stop()
			else:
				input_timer.stop()
				_reset_stack()
