extends CharacterBlueprint

var Hadoken : SpecialInput
var Reload : SpecialInput

func _hadoken_completed() -> void:
	print("HADOKEN!!!")

func _reload_completed() -> void:
	print("RELOAD!!!")

func _ready() -> void:
	Hadoken = SpecialInput.new()
	Hadoken.input_list_right = [game_input.DOWN,game_input.DOWN_RIGHT,game_input.DOWN_RELEASED,game_input.RIGHT,game_input.RIGHT_RELEASED,game_input.LIGHT]
	Hadoken.input_list_left = [game_input.DOWN,game_input.DOWN_LEFT,game_input.DOWN_RELEASED,game_input.LEFT,game_input.LEFT_RELEASED,game_input.LIGHT]
	Hadoken._initialize(self)
	Hadoken.input_completed.connect(_hadoken_completed)
	
	Reload = SpecialInput.new()
	Reload.input_list_right = [game_input.DOWN,game_input.DOWN_RELEASED,game_input.DOWN,game_input.DOWN_RELEASED,game_input.LIGHT]
	Reload.input_list_left = [game_input.DOWN,game_input.DOWN_RELEASED,game_input.DOWN,game_input.DOWN_RELEASED,game_input.LIGHT]
	Reload._initialize(self)
	Reload.input_completed.connect(_reload_completed)
