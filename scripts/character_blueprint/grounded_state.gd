class_name GroundedState
extends State

@export var player : CharacterBlueprint

func _ready() -> void:
	super()

func _physics_process(delta: float) -> void:
	var directional_input : Vector2 = Input.get_vector("game_up","game_left","game_down","game_right")
