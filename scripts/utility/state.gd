class_name State
extends Node

func _set_processes(switch: bool) -> void:
	set_process(switch)
	set_physics_process(switch)
	set_process_input(switch)

func _enter_state() -> void:
	_set_processes(true)

func _exit_state() -> void:
	_set_processes(false)

func _ready() -> void:
	_set_processes(false)
