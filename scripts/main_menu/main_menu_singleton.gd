extends Node2D


const DUMMYNETWORKADAPTOR = preload("res://addons/delta_rollback/DummyNetworkAdaptor.gd")


@onready var local_or_online_menu := $CanvasLayer/LocalOrOnlineMenu

func _on_local_play_button_pressed() -> void:
	local_or_online_menu.visible = false
	#$ClientPlayer.input_prefix = "player_two_"
	SyncManager.network_adaptor = DUMMYNETWORKADAPTOR.new()
	SyncManager.start()


func _on_online_play_button_pressed() -> void:
	SyncManager.reset_network_adaptor()
	print("Not yet implemented.")
