extends Control

@onready var panel_container := $PanelContainer
@onready var server_port_line_edit := $PanelContainer/GridContainer/ServerPortLineEdit
@onready var offer_line_edit := $PanelContainer/GridContainer/OfferLineEdit
@onready var answer_line_edit := $PanelContainer/GridContainer/AnswerLineEdit

func _on_create_server_button_pressed() -> void:
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_server(int(server_port_line_edit.text))
	panel_container.visible = false

func _on_create_offer_button_pressed() -> void:
	var peer = WebRTCPeerConnection.new()
	var channel = peer.create_data_channel("message", {"id" : int(offer_line_edit.text), "negotiated" : true})
	peer.create_offer()

func _on_asnwer_button_pressed() -> void:
	var peer = WebRTCPeerConnection.new()
	var channel = peer.create_data_channel("message", {"id" : int(offer_line_edit.text), "negotiated" : true})

func _process(delta: float) -> void:
	pass
