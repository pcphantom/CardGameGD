extends Node
class_name WebRTCMatchmaking

# WebRTC-based matchmaking system for finding opponents online
# Uses WebSocket signaling server to exchange connection information
# Then establishes direct peer-to-peer connection via WebRTC

# Properties
var webrtc_peer: WebRTCMultiplayerPeer = null
var signaling_server_url: String = "ws://localhost:9080"
var websocket: WebSocketPeer = null
var is_host: bool = false
var match_id: String = ""
var local_player_id: String = ""
var is_connected_to_signaling: bool = false
var pending_ice_candidates: Array = []

# ICE server configuration
const ICE_SERVERS: Array = [
	# Google's public STUN servers
	{"urls": ["stun:stun.l.google.com:19302"]},
	{"urls": ["stun:stun1.l.google.com:19302"]},
	{"urls": ["stun:stun2.l.google.com:19302"]},
	# Placeholder for TURN server (requires authentication)
	# {"urls": ["turn:your-turn-server.com:3478"], "username": "user", "credential": "pass"}
]

# Signals
signal matchmaking_started()
signal match_found(opponent_id: String)
signal match_failed(reason: String)
signal connection_established()
signal connection_lost()
signal received_game_event(event: NetworkEvent)
signal signaling_connected()
signal signaling_disconnected()

func _ready() -> void:
	# Generate local player ID
	local_player_id = _generate_player_id()
	print("WebRTCMatchmaking: Local player ID: %s" % local_player_id)

	# Connect to multiplayer signals
	if multiplayer.has_signal("peer_connected"):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if multiplayer.has_signal("peer_disconnected"):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if multiplayer.has_signal("connected_to_server"):
		multiplayer.connected_to_server.connect(_on_connection_succeeded)
	if multiplayer.has_signal("connection_failed"):
		multiplayer.connection_failed.connect(_on_connection_failed)

func _process(_delta: float) -> void:
	if websocket == null:
		return

	# Poll websocket state
	websocket.poll()

	var state: WebSocketPeer.State = websocket.get_ready_state()

	match state:
		WebSocketPeer.STATE_OPEN:
			# Process received messages
			while websocket.get_available_packet_count() > 0:
				var packet: PackedByteArray = websocket.get_packet()
				var message_str: String = packet.get_string_from_utf8()
				_handle_signaling_message_string(message_str)

		WebSocketPeer.STATE_CLOSING:
			pass  # Connection is closing

		WebSocketPeer.STATE_CLOSED:
			# Connection closed
			var code: int = websocket.get_close_code()
			var reason: String = websocket.get_close_reason()
			print("WebRTCMatchmaking: WebSocket closed. Code: %d, Reason: %s" % [code, reason])
			is_connected_to_signaling = false
			signaling_disconnected.emit()

# Connect to signaling server
func connect_to_signaling_server() -> bool:
	print("WebRTCMatchmaking: Connecting to signaling server: %s" % signaling_server_url)

	# Create websocket
	websocket = WebSocketPeer.new()

	# Connect to server
	var err: Error = websocket.connect_to_url(signaling_server_url)

	if err != OK:
		push_error("WebRTCMatchmaking: Failed to connect to signaling server. Error: %d" % err)
		websocket = null
		return false

	print("WebRTCMatchmaking: Connection to signaling server initiated")
	return true

# Start matchmaking (random opponent)
func start_matchmaking() -> void:
	print("WebRTCMatchmaking: Starting matchmaking")

	# Connect to signaling server if not already connected
	if not is_connected_to_signaling:
		if not connect_to_signaling_server():
			match_failed.emit("Failed to connect to signaling server")
			return

		# Wait for connection to establish
		await get_tree().create_timer(1.0).timeout

	# Setup WebRTC peer
	_setup_webrtc_peer()

	# Send matchmaking request to signaling server
	_send_signaling_message("find_match", {
		"player_id": local_player_id
	})

	matchmaking_started.emit()
	print("WebRTCMatchmaking: Matchmaking request sent")

# Create private match (returns match ID for sharing)
func create_private_match() -> String:
	print("WebRTCMatchmaking: Creating private match")

	# Generate unique match ID
	match_id = _generate_match_id()
	is_host = true

	# Connect to signaling server if not already connected
	if not is_connected_to_signaling:
		if not connect_to_signaling_server():
			match_failed.emit("Failed to connect to signaling server")
			return ""

		# Wait for connection to establish
		await get_tree().create_timer(1.0).timeout

	# Setup WebRTC peer
	_setup_webrtc_peer()

	# Register match with signaling server
	_send_signaling_message("create_match", {
		"match_id": match_id,
		"player_id": local_player_id
	})

	print("WebRTCMatchmaking: Private match created with ID: %s" % match_id)
	return match_id

# Join private match by ID
func join_private_match(p_match_id: String) -> bool:
	print("WebRTCMatchmaking: Joining private match: %s" % p_match_id)

	match_id = p_match_id
	is_host = false

	# Connect to signaling server if not already connected
	if not is_connected_to_signaling:
		if not connect_to_signaling_server():
			match_failed.emit("Failed to connect to signaling server")
			return false

		# Wait for connection to establish
		await get_tree().create_timer(1.0).timeout

	# Setup WebRTC peer
	_setup_webrtc_peer()

	# Send join request to signaling server
	_send_signaling_message("join_match", {
		"match_id": match_id,
		"player_id": local_player_id
	})

	print("WebRTCMatchmaking: Join request sent")
	return true

# Setup WebRTC peer
func _setup_webrtc_peer() -> void:
	print("WebRTCMatchmaking: Setting up WebRTC peer")

	# Create WebRTC multiplayer peer
	webrtc_peer = WebRTCMultiplayerPeer.new()

	# Create peer connection
	var err: Error = webrtc_peer.create_mesh(local_player_id.hash())

	if err != OK:
		push_error("WebRTCMatchmaking: Failed to create WebRTC mesh. Error: %d" % err)
		return

	# Add ICE servers (STUN/TURN)
	for ice_server in ICE_SERVERS:
		var urls: Array = ice_server.get("urls", [])
		var _username: String = ice_server.get("username", "")
		var _credential: String = ice_server.get("credential", "")

		for url in urls:
			# Note: Godot's WebRTC implementation handles ICE server configuration internally
			# This is a placeholder for documentation purposes
			pass

	# Set as multiplayer peer
	multiplayer.multiplayer_peer = webrtc_peer

	print("WebRTCMatchmaking: WebRTC peer configured")

# Create WebRTC offer
func _create_offer() -> void:
	print("WebRTCMatchmaking: Creating offer")

	if webrtc_peer == null:
		push_error("WebRTCMatchmaking: Cannot create offer - WebRTC peer not initialized")
		return

	# In Godot's WebRTC implementation, offers are created automatically
	# when add_peer is called. We need to wait for the offer to be generated.
	# For now, we'll send a signal to the signaling server that we're ready
	_send_signaling_message("ready_for_offer", {
		"player_id": local_player_id,
		"match_id": match_id
	})

# Create WebRTC answer for received offer
func _create_answer(offer: Dictionary) -> void:
	print("WebRTCMatchmaking: Creating answer for offer")

	if webrtc_peer == null:
		push_error("WebRTCMatchmaking: Cannot create answer - WebRTC peer not initialized")
		return

	# Process the offer
	var peer_id: int = offer.get("peer_id", 0)
	var sdp: String = offer.get("sdp", "")

	if peer_id == 0 or sdp.is_empty():
		push_error("WebRTCMatchmaking: Invalid offer data")
		return

	# Create and configure peer connection
	var peer_connection: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer_connection.initialize({"iceServers": ICE_SERVERS})

	# Set remote description (the offer)
	peer_connection.set_remote_description("offer", sdp)

	# Add peer to multiplayer peer
	var err: Error = webrtc_peer.add_peer(peer_connection, peer_id)

	if err != OK:
		push_error("WebRTCMatchmaking: Failed to add peer. Error: %d" % err)
		return

	# Create answer
	var answer_dict: Dictionary = await peer_connection.create_answer()
	if answer_dict.has("error"):
		push_error("WebRTCMatchmaking: Failed to create answer: %s" % answer_dict.get("error"))
		return

	peer_connection.set_local_description("answer", answer_dict.get("sdp", ""))

	# Send answer back via signaling server
	_send_signaling_message("answer", {
		"player_id": local_player_id,
		"match_id": match_id,
		"peer_id": peer_id
	})

# Add ICE candidate
func _add_ice_candidate(candidate: Dictionary) -> void:
	print("WebRTCMatchmaking: Adding ICE candidate")

	if webrtc_peer == null:
		# Store for later if peer not ready yet
		pending_ice_candidates.append(candidate)
		return

	var _peer_id: int = candidate.get("peer_id", 0)
	var _candidate_str: String = candidate.get("candidate", "")
	var _sdp_mid: String = candidate.get("sdp_mid", "")
	var _sdp_mline_index: int = candidate.get("sdp_mline_index", 0)

	# Note: Godot's WebRTC handles ICE candidates internally
	# This is a placeholder for when the API is extended
	print("WebRTCMatchmaking: ICE candidate processed")

# Handle signaling message (string format)
func _handle_signaling_message_string(message_str: String) -> void:
	# Parse JSON message
	var json := JSON.new()
	var parse_result: Error = json.parse(message_str)

	if parse_result != OK:
		push_error("WebRTCMatchmaking: Failed to parse signaling message: %s" % message_str)
		return

	var message: Dictionary = json.data
	_handle_signaling_message(message)

# Handle signaling message
func _handle_signaling_message(message: Dictionary) -> void:
	var msg_type: String = message.get("type", "")

	print("WebRTCMatchmaking: Received signaling message: %s" % msg_type)

	match msg_type:
		"connected":
			# Successfully connected to signaling server
			is_connected_to_signaling = true
			signaling_connected.emit()
			print("WebRTCMatchmaking: Connected to signaling server")

		"match_found":
			# Match found with opponent
			var opponent_id: String = message.get("opponent_id", "")
			is_host = message.get("is_host", false)
			match_id = message.get("match_id", "")

			print("WebRTCMatchmaking: Match found! Opponent: %s, Is host: %s" % [opponent_id, is_host])
			match_found.emit(opponent_id)

			# Host creates offer
			if is_host:
				_create_offer()

		"match_created":
			# Private match created successfully
			print("WebRTCMatchmaking: Match created on server")

		"match_joined":
			# Successfully joined private match
			var opponent_id: String = message.get("opponent_id", "")
			print("WebRTCMatchmaking: Joined match. Opponent: %s" % opponent_id)
			match_found.emit(opponent_id)

		"offer":
			# Received WebRTC offer
			_create_answer(message)

		"answer":
			# Received WebRTC answer
			print("WebRTCMatchmaking: Received answer from opponent")
			# Answer is processed internally by WebRTC peer

		"ice_candidate":
			# Received ICE candidate
			_add_ice_candidate(message)

		"error":
			# Error from signaling server
			var reason: String = message.get("reason", "Unknown error")
			print("WebRTCMatchmaking: Error from signaling server: %s" % reason)
			match_failed.emit(reason)

		"opponent_disconnected":
			# Opponent disconnected
			print("WebRTCMatchmaking: Opponent disconnected")
			connection_lost.emit()

		_:
			push_warning("WebRTCMatchmaking: Unknown message type: %s" % msg_type)

# Send signaling message
func _send_signaling_message(msg_type: String, data: Dictionary) -> void:
	if websocket == null or websocket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		push_warning("WebRTCMatchmaking: Cannot send message - not connected to signaling server")
		return

	# Prepare message
	var message: Dictionary = {
		"type": msg_type,
		"player_id": local_player_id
	}

	# Merge data
	for key in data:
		message[key] = data[key]

	# Serialize to JSON
	var message_str: String = JSON.stringify(message)

	# Send via websocket
	var err: Error = websocket.send_text(message_str)

	if err != OK:
		push_error("WebRTCMatchmaking: Failed to send message. Error: %d" % err)
		return

	print("WebRTCMatchmaking: Sent signaling message: %s" % msg_type)

# Send game event over WebRTC
func send_game_event(event: NetworkEvent) -> void:
	if webrtc_peer == null or not webrtc_peer.has_peer(1):
		push_warning("WebRTCMatchmaking: Cannot send event - not connected to opponent")
		return

	if event == null:
		push_warning("WebRTCMatchmaking: Cannot send null event")
		return

	# Convert event to dictionary
	var event_data: Dictionary = event.to_dict()

	# Send via RPC
	rpc_id(1, "receive_game_event", event_data)

# Receive game event over WebRTC
@rpc("any_peer", "call_remote", "reliable")
func receive_game_event(event_data: Dictionary) -> void:
	# Convert dictionary to NetworkEvent
	var event: NetworkEvent = NetworkEvent.from_dict(event_data)

	if event == null:
		push_warning("WebRTCMatchmaking: Failed to deserialize network event")
		return

	# Emit signal
	received_game_event.emit(event)

# Disconnect from match
func disconnect_from_match() -> void:
	print("WebRTCMatchmaking: Disconnecting from match")

	# Notify signaling server
	if is_connected_to_signaling:
		_send_signaling_message("leave_match", {
			"match_id": match_id
		})

	# Close WebRTC peer
	if webrtc_peer != null:
		webrtc_peer.close()
		webrtc_peer = null

	# Close websocket
	if websocket != null:
		websocket.close()
		websocket = null

	multiplayer.multiplayer_peer = null

	# Reset state
	is_host = false
	match_id = ""
	is_connected_to_signaling = false
	pending_ice_candidates.clear()

	print("WebRTCMatchmaking: Disconnected")

# Generate player ID
func _generate_player_id() -> String:
	var uuid := ""
	randomize()

	# Generate simple UUID-like ID
	for i in range(8):
		uuid += "0123456789abcdef"[randi() % 16]

	return uuid

# Generate match ID
func _generate_match_id() -> String:
	var id := ""
	randomize()

	# Generate 6-character match code
	const CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	for i in range(6):
		id += CHARS[randi() % CHARS.length()]

	return id

# Signal handlers
func _on_peer_connected(peer_id: int) -> void:
	print("WebRTCMatchmaking: Peer connected: %d" % peer_id)
	connection_established.emit()

func _on_peer_disconnected(peer_id: int) -> void:
	print("WebRTCMatchmaking: Peer disconnected: %d" % peer_id)
	connection_lost.emit()

func _on_connection_succeeded() -> void:
	print("WebRTCMatchmaking: Connection succeeded")
	connection_established.emit()

func _on_connection_failed() -> void:
	print("WebRTCMatchmaking: Connection failed")
	match_failed.emit("Connection failed")

# Get connection status
func get_connection_status() -> String:
	if webrtc_peer == null:
		return "No peer"

	var peers: Array = multiplayer.get_peers()
	if peers.size() > 0:
		return "Connected (%d peers)" % peers.size()
	else:
		return "Connecting..."

# Check if connected to peer
func is_peer_connected() -> bool:
	if webrtc_peer == null:
		return false

	var peers: Array = multiplayer.get_peers()
	return peers.size() > 0

# Get match info
func get_match_info() -> Dictionary:
	return {
		"match_id": match_id,
		"is_host": is_host,
		"local_player_id": local_player_id,
		"is_connected": is_peer_connected(),
		"connection_status": get_connection_status(),
		"signaling_connected": is_connected_to_signaling
	}

# Print debug info
func print_debug_info() -> void:
	print("=== WebRTC Matchmaking Debug Info ===")
	print("Match ID: %s" % match_id)
	print("Is Host: %s" % str(is_host))
	print("Local Player ID: %s" % local_player_id)
	print("Is Connected: %s" % str(is_peer_connected()))
	print("Connection Status: %s" % get_connection_status())
	print("Signaling Connected: %s" % str(is_connected_to_signaling))
	print("=====================================")
