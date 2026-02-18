extends Node

enum Message {
	ID, JOIN, USER_CONNECTED, USER_DISCONNECTED, LOBBY, CANDIDATE, OFFER, ANSWER, CHECKIN
}

var peer := WebSocketMultiplayerPeer.new()

func _start_server() -> void:
	peer.create_server(8915)
	print("start server")

func _on_start_server_pressed() -> void:
	_start_server()

func _process(delta: float) -> void:
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var data_string = packet.get_string_from_utf8()
			var data = JSON.parse_string(data_string)
			print(data)
