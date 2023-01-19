extends Control

const _DEFAULT_HOST_PORT : int = 9111

var _current_tcp_server : TCP_Server
var _current_tcp_peer : StreamPeerTCP
var _clients_array : Array
var _btn_label_text : String
var _answer_body : String

func _ready():
	set_process(false)
	_set_server_listening()
	set_process(true)

func _process(_delta):
	if _current_tcp_server.is_connection_available():
		_create_new_client()
		_create_new_requested_button()
		_add_new_client_to_array()

func _set_server_listening():
	_current_tcp_server = TCP_Server.new()
# warning-ignore:return_value_discarded
	_current_tcp_server.listen(_DEFAULT_HOST_PORT)

func _create_new_client():
	_current_tcp_peer = _current_tcp_server.take_connection()
	
#	var returned_string = _current_tcp_peer.get_data(_current_tcp_peer.get_available_bytes())[1].get_string_from_utf8()
	var request_string : String = _current_tcp_peer.get_string(_current_tcp_peer.get_available_bytes())
	var requested_route : String = request_string.split(" HTTP")[0].split("GET ")[1]
	
	if requested_route == "/":
		_btn_label_text = "Empty route"
	elif requested_route == "/home":
		_btn_label_text = "Welcome home"
	elif requested_route == "/myaddress":
		_btn_label_text = _current_tcp_peer.get_connected_host() + ":" + str(_current_tcp_peer.get_connected_port())

func _create_new_requested_button():
	var requested_button = Button.new()
	var req_btn_label = Label.new()
	
	self.add_child(requested_button)
	requested_button.rect_size = Vector2(1000, 160)
	requested_button.rect_position = Vector2(90, 900)
	
	requested_button.add_child(req_btn_label)
	req_btn_label.rect_position = Vector2(57, 52)
	req_btn_label.text = _btn_label_text
	
	requested_button.connect("pressed", self, "_on_requested_btn_pressed")
	
func _add_new_client_to_array():
	_clients_array.append(_current_tcp_peer)

func _on_AnswerToRequestBtn_pressed():
	_answer_body = "hello from host: " + _current_tcp_peer.get_connected_host() + ":" + str(_current_tcp_peer.get_connected_port())
	
	var _err = _current_tcp_peer.put_data(("HTTP/1.1 %d\r\n\r\n" % 200).to_utf8())
	var _err2 = _current_tcp_peer.put_data(_answer_body.to_utf8())

func _on_AnswerToAllRequestsBtn_pressed():
	
	for client in _clients_array:
		_answer_body = "hello from host: " + client.get_connected_host() + ":" + str(client.get_connected_port())
		client.put_data(("HTTP/1.1 %d\r\n\r\n" % 200).to_utf8())
		client.put_data(_answer_body.to_utf8())

func _on_requested_btn_pressed():
		_answer_body = _btn_label_text
	
		var _err = _current_tcp_peer.put_data(("HTTP/1.1 %d\r\n\r\n" % 200).to_utf8())
		var _err2 = _current_tcp_peer.put_data(_answer_body.to_utf8())
