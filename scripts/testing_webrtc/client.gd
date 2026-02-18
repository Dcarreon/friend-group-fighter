extends Node

enum Message {
	ID, JOIN, USER_CONNECTED, USER_DISCONNECTED, LOBBY, CANDIDATE, OFFER, ANSWER, CHECKIN
}

var peer := WebSocketMultiplayerPeer.new()

func _connect_to_server(ip) -> void:
	peer.create_client("ws://127.0.0.1:8915")
	print("started client")


func _on_start_client_pressed() -> void:
	_connect_to_server("")


func _on_send_data_pressed() -> void:
	var message = {
		"message" : Message.JOIN,
		"data" : "test"
	}
	
	var message_bytes = JSON.stringify(message).to_utf8_buffer()
	
	peer.put_packet(message_bytes)

func _process(delta: float) -> void:
	peer.poll()
