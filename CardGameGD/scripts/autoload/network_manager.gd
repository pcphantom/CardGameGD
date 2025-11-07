extends Node

# NetworkManager Autoload Singleton
#
# Unified multiplayer manager supporting both:
# - P2P direct connections (ENet)
# - WebRTC matchmaking
#
# Phase 7: Full P2P and WebRTC integration
#
# Accessible globally via: NetworkManager.method_name()

# Connection type enum
enum ConnectionType {
	NONE,
	P2P_DIRECT,
	WEBRTC_MATCHMAKING
}

# Properties
var current_connection_type: ConnectionType = ConnectionType.NONE
var p2p_connection: P2PConnection = null
var webrtc_matchmaking: WebRTCMatchmaking = null
var is_multiplayer_game: bool = false
var local_player_id: String = ""
var remote_player_id: String = ""
var pending_events: Array[NetworkEvent] = []
var is_my_turn: bool = false

# Remote player info
var remote_player_data: Dictionary = {}

# Signals
signal multiplayer_connected()
signal multiplayer_disconnected()
signal opponent_info_received(player_data: Dictionary)
signal network_event_received(event: NetworkEvent)
signal turn_started()
signal turn_ended()

func _ready() -> void:
	print("NetworkManager: Initializing unified multiplayer manager")

	# Generate local player ID
	local_player_id = _generate_uuid()
	print("NetworkManager: Local player ID: %s" % local_player_id)

	# Create P2PConnection instance
	p2p_connection = P2PConnection.new()
	p2p_connection.name = "P2PConnection"
	add_child(p2p_connection)

	# Connect P2PConnection signals
	p2p_connection.connection_succeeded.connect(_on_connection_succeeded)
	p2p_connection.connection_failed.connect(_on_connection_failed)
	p2p_connection.player_connected.connect(_on_player_connected)
	p2p_connection.player_disconnected.connect(_on_player_disconnected)
	p2p_connection.received_player_info.connect(_on_player_info_received)
	p2p_connection.received_event.connect(_on_network_event_received)

	# Create WebRTCMatchmaking instance
	webrtc_matchmaking = WebRTCMatchmaking.new()
	webrtc_matchmaking.name = "WebRTCMatchmaking"
	add_child(webrtc_matchmaking)

	# Connect WebRTCMatchmaking signals
	webrtc_matchmaking.match_found.connect(_on_match_found)
	webrtc_matchmaking.match_failed.connect(_on_match_failed)
	webrtc_matchmaking.connection_established.connect(_on_connection_succeeded)
	webrtc_matchmaking.connection_lost.connect(_on_connection_failed)
	webrtc_matchmaking.received_game_event.connect(_on_network_event_received)

	print("NetworkManager: Initialization complete")

# =============================================================================
# P2P DIRECT CONNECTION METHODS
# =============================================================================

# Start P2P server (host)
func start_p2p_server(port: int = 5000) -> bool:
	print("NetworkManager: Starting P2P server on port %d" % port)

	if current_connection_type != ConnectionType.NONE:
		push_error("NetworkManager: Already connected with type: %s" % _connection_type_to_string(current_connection_type))
		return false

	var result: bool = p2p_connection.create_server(port)

	if result:
		current_connection_type = ConnectionType.P2P_DIRECT
		is_multiplayer_game = true
		print("NetworkManager: P2P server started successfully")
		GameManager.log_message("Hosting P2P game on port %d" % port)
	else:
		push_error("NetworkManager: Failed to start P2P server")
		GameManager.log_message("Failed to host P2P game")

	return result

# Connect to P2P host (client)
func connect_to_p2p_host(host: String, port: int = 5000) -> bool:
	print("NetworkManager: Connecting to P2P host at %s:%d" % [host, port])

	if current_connection_type != ConnectionType.NONE:
		push_error("NetworkManager: Already connected with type: %s" % _connection_type_to_string(current_connection_type))
		return false

	var result: bool = p2p_connection.connect_to_server(host, port)

	if result:
		current_connection_type = ConnectionType.P2P_DIRECT
		is_multiplayer_game = true
		print("NetworkManager: P2P connection initiated")
		GameManager.log_message("Connecting to P2P host at %s:%d" % [host, port])
	else:
		push_error("NetworkManager: Failed to connect to P2P host")
		GameManager.log_message("Failed to connect to P2P host")

	return result

# =============================================================================
# WEBRTC MATCHMAKING METHODS
# =============================================================================

# Start WebRTC matchmaking (random opponent)
func start_webrtc_matchmaking() -> void:
	print("NetworkManager: Starting WebRTC matchmaking")

	if current_connection_type != ConnectionType.NONE:
		push_error("NetworkManager: Already connected with type: %s" % _connection_type_to_string(current_connection_type))
		return

	current_connection_type = ConnectionType.WEBRTC_MATCHMAKING
	is_multiplayer_game = true

	webrtc_matchmaking.start_matchmaking()
	print("NetworkManager: WebRTC matchmaking started")
	GameManager.log_message("Searching for opponent...")

# Create private WebRTC match (returns match ID)
func create_private_webrtc_match() -> String:
	print("NetworkManager: Creating private WebRTC match")

	if current_connection_type != ConnectionType.NONE:
		push_error("NetworkManager: Already connected with type: %s" % _connection_type_to_string(current_connection_type))
		return ""

	current_connection_type = ConnectionType.WEBRTC_MATCHMAKING
	is_multiplayer_game = true

	var match_id: String = await webrtc_matchmaking.create_private_match()
	print("NetworkManager: Private WebRTC match created: %s" % match_id)
	GameManager.log_message("Private match created: %s" % match_id)

	return match_id

# Join private WebRTC match by ID
func join_private_webrtc_match(match_id: String) -> bool:
	print("NetworkManager: Joining private WebRTC match: %s" % match_id)

	if current_connection_type != ConnectionType.NONE:
		push_error("NetworkManager: Already connected with type: %s" % _connection_type_to_string(current_connection_type))
		return false

	current_connection_type = ConnectionType.WEBRTC_MATCHMAKING
	is_multiplayer_game = true

	var result: bool = await webrtc_matchmaking.join_private_match(match_id)

	if result:
		print("NetworkManager: Joining private match: %s" % match_id)
		GameManager.log_message("Joining private match: %s" % match_id)
	else:
		push_error("NetworkManager: Failed to join private match")
		GameManager.log_message("Failed to join private match")
		current_connection_type = ConnectionType.NONE
		is_multiplayer_game = false

	return result

# =============================================================================
# UNIFIED EVENT TRANSMISSION
# =============================================================================

# Send network event (routes to appropriate connection)
func send_network_event(event: NetworkEvent) -> void:
	if event == null:
		push_warning("NetworkManager: Cannot send null event")
		return

	if current_connection_type == ConnectionType.NONE:
		push_warning("NetworkManager: Not connected, cannot send event")
		return

	match current_connection_type:
		ConnectionType.P2P_DIRECT:
			if p2p_connection.is_connected:
				p2p_connection.send_event(event)
				print("NetworkManager: Sent event via P2P: %s" % event.get_event_type_string())
			else:
				push_warning("NetworkManager: P2P not connected, queueing event")
				pending_events.append(event)

		ConnectionType.WEBRTC_MATCHMAKING:
			if webrtc_matchmaking.is_peer_connected():
				webrtc_matchmaking.send_game_event(event)
				print("NetworkManager: Sent event via WebRTC: %s" % event.get_event_type_string())
			else:
				push_warning("NetworkManager: WebRTC not connected, queueing event")
				pending_events.append(event)

		_:
			push_warning("NetworkManager: Unknown connection type: %d" % current_connection_type)

# Handle received network event
func _on_network_event_received(event: NetworkEvent) -> void:
	if event == null:
		push_warning("NetworkManager: Received null event")
		return

	print("NetworkManager: Received event: %s from player %s" % [event.get_event_type_string(), event.get_player_id()])

	# Handle special event types
	match event.get_event_type():
		NetworkEvent.EventType.REMOTE_PLAYER_INFO_INIT:
			_handle_player_info_init(event)
			return

		_:
			# Emit generic event signal for game logic
			network_event_received.emit(event)

	# Check for turn signal in event data
	if event.player_data.has("your_turn") and event.player_data["your_turn"]:
		_handle_turn_start()

# =============================================================================
# PLAYER INFO EXCHANGE
# =============================================================================

# Send player info to opponent
func send_player_info(player_data: Dictionary) -> void:
	print("NetworkManager: Sending player info: %s" % str(player_data))

	if current_connection_type == ConnectionType.NONE:
		push_warning("NetworkManager: Not connected, cannot send player info")
		return

	# Create player info event
	var event := NetworkEvent.create_with_player(NetworkEvent.EventType.REMOTE_PLAYER_INFO_INIT, player_data)

	# Send via appropriate connection
	match current_connection_type:
		ConnectionType.P2P_DIRECT:
			p2p_connection.send_player_info(player_data)
			print("NetworkManager: Player info sent via P2P")

		ConnectionType.WEBRTC_MATCHMAKING:
			webrtc_matchmaking.send_game_event(event)
			print("NetworkManager: Player info sent via WebRTC")

		_:
			push_warning("NetworkManager: Unknown connection type")

# Handle player info initialization
func _handle_player_info_init(event: NetworkEvent) -> void:
	print("NetworkManager: Received player info init from opponent")

	# Store remote player data
	remote_player_data = event.get_player_data()
	remote_player_id = event.get_player_id()

	print("NetworkManager: Opponent player ID: %s" % remote_player_id)
	print("NetworkManager: Opponent data: %s" % str(remote_player_data))

	# Emit signal
	opponent_info_received.emit(remote_player_data)
	GameManager.log_message("Opponent info received: %s" % remote_player_data.get("name", "Unknown"))

# =============================================================================
# TURN MANAGEMENT
# =============================================================================

# Send turn end signal to opponent
func send_turn_end_signal() -> void:
	print("NetworkManager: Ending turn, sending signal to opponent")

	if not is_my_turn:
		push_warning("NetworkManager: Not your turn")
		return

	# Create "Your turn" event
	var event := NetworkEvent.new(NetworkEvent.EventType.CARD_END_TURN_CHECK, local_player_id)
	event.player_data["your_turn"] = true

	# Send event
	send_network_event(event)

	# Update local state
	is_my_turn = false
	turn_ended.emit()

	print("NetworkManager: Turn ended")
	GameManager.log_message("Turn ended, waiting for opponent")

# Handle turn start
func _handle_turn_start() -> void:
	print("NetworkManager: Turn started")

	# Update state
	is_my_turn = true

	# Process pending events
	if pending_events.size() > 0:
		print("NetworkManager: Processing %d pending events" % pending_events.size())
		for event in pending_events:
			send_network_event(event)
		pending_events.clear()

	# Emit signal
	turn_started.emit()
	GameManager.log_message("Your turn!")

# =============================================================================
# CONNECTION STATE MANAGEMENT
# =============================================================================

# Disconnect from multiplayer game
func disconnect_multiplayer() -> void:
	print("NetworkManager: Disconnecting from multiplayer game")

	# Disconnect based on connection type
	match current_connection_type:
		ConnectionType.P2P_DIRECT:
			p2p_connection.disconnect_from_game()
			print("NetworkManager: Disconnected from P2P")

		ConnectionType.WEBRTC_MATCHMAKING:
			webrtc_matchmaking.disconnect_from_match()
			print("NetworkManager: Disconnected from WebRTC")

		_:
			print("NetworkManager: No active connection to disconnect")

	# Reset state
	current_connection_type = ConnectionType.NONE
	is_multiplayer_game = false
	remote_player_id = ""
	remote_player_data.clear()
	pending_events.clear()
	is_my_turn = false

	# Emit signal
	multiplayer_disconnected.emit()
	GameManager.log_message("Disconnected from multiplayer")

	print("NetworkManager: Disconnection complete")

# Get connection status string
func get_connection_status() -> String:
	match current_connection_type:
		ConnectionType.NONE:
			return "Not connected"

		ConnectionType.P2P_DIRECT:
			return "P2P: %s" % p2p_connection.get_connection_status()

		ConnectionType.WEBRTC_MATCHMAKING:
			return "WebRTC: %s" % webrtc_matchmaking.get_connection_status()

		_:
			return "Unknown connection type"

# Check if connected to multiplayer
func is_multiplayer_connected() -> bool:
	match current_connection_type:
		ConnectionType.NONE:
			return false

		ConnectionType.P2P_DIRECT:
			return p2p_connection.is_connected

		ConnectionType.WEBRTC_MATCHMAKING:
			return webrtc_matchmaking.is_peer_connected()

		_:
			return false

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

# Connection succeeded (both P2P and WebRTC)
func _on_connection_succeeded() -> void:
	print("NetworkManager: Connection succeeded")

	# Emit signal
	multiplayer_connected.emit()
	GameManager.log_message("Connected to opponent!")

# Connection failed (both P2P and WebRTC)
func _on_connection_failed() -> void:
	print("NetworkManager: Connection failed")

	# Reset state
	current_connection_type = ConnectionType.NONE
	is_multiplayer_game = false

	GameManager.log_message("Connection failed")

# Player connected (P2P only)
func _on_player_connected(peer_id: int) -> void:
	print("NetworkManager: Player connected: %d" % peer_id)

	# Store remote player ID
	remote_player_id = str(peer_id)

	# If we're the host, we start first
	if current_connection_type == ConnectionType.P2P_DIRECT and p2p_connection.is_server:
		is_my_turn = true
		print("NetworkManager: Host - your turn first")
		turn_started.emit()

	# Emit connection signal
	multiplayer_connected.emit()
	GameManager.log_message("Opponent connected!")

# Player disconnected (P2P only)
func _on_player_disconnected(peer_id: int) -> void:
	print("NetworkManager: Player disconnected: %d" % peer_id)

	# Clear remote player
	if remote_player_id == str(peer_id):
		remote_player_id = ""
		remote_player_data.clear()

	# Emit signal
	multiplayer_disconnected.emit()
	GameManager.log_message("Opponent disconnected")

# Player info received (P2P only)
func _on_player_info_received(player_data: Dictionary) -> void:
	print("NetworkManager: Received player info: %s" % str(player_data))

	# Store remote player data
	remote_player_data = player_data

	# Emit signal
	opponent_info_received.emit(player_data)
	GameManager.log_message("Opponent info received")

# Match found (WebRTC only)
func _on_match_found(opponent_id: String) -> void:
	print("NetworkManager: Match found with opponent: %s" % opponent_id)

	# Store opponent ID
	remote_player_id = opponent_id

	# Determine turn order (host goes first)
	if webrtc_matchmaking.is_host:
		is_my_turn = true
		print("NetworkManager: Host - your turn first")
		turn_started.emit()

	GameManager.log_message("Match found! Connecting to opponent...")

# Match failed (WebRTC only)
func _on_match_failed(reason: String) -> void:
	print("NetworkManager: Match failed: %s" % reason)

	# Reset state
	current_connection_type = ConnectionType.NONE
	is_multiplayer_game = false

	GameManager.log_message("Matchmaking failed: %s" % reason)

# =============================================================================
# UTILITY METHODS
# =============================================================================

# Generate UUID for player ID
func _generate_uuid() -> String:
	var uuid := ""
	randomize()

	# Generate UUID in format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
	for i in range(36):
		if i == 8 or i == 13 or i == 18 or i == 23:
			uuid += "-"
		elif i == 14:
			uuid += "4"  # Version 4 UUID
		elif i == 19:
			uuid += ["8", "9", "a", "b"][randi() % 4]  # Variant
		else:
			uuid += "0123456789abcdef"[randi() % 16]

	return uuid

# Convert connection type to string
func _connection_type_to_string(type: ConnectionType) -> String:
	match type:
		ConnectionType.NONE:
			return "NONE"
		ConnectionType.P2P_DIRECT:
			return "P2P_DIRECT"
		ConnectionType.WEBRTC_MATCHMAKING:
			return "WEBRTC_MATCHMAKING"
		_:
			return "UNKNOWN"

# Get connection info (debug)
func get_connection_info() -> Dictionary:
	return {
		"connection_type": _connection_type_to_string(current_connection_type),
		"is_multiplayer_game": is_multiplayer_game,
		"local_player_id": local_player_id,
		"remote_player_id": remote_player_id,
		"is_my_turn": is_my_turn,
		"is_connected": is_multiplayer_connected(),
		"connection_status": get_connection_status(),
		"pending_events": pending_events.size(),
		"has_remote_player_data": not remote_player_data.is_empty()
	}

# Print debug info
func print_debug_info() -> void:
	print("=== NetworkManager Debug Info ===")
	print("Connection Type: %s" % _connection_type_to_string(current_connection_type))
	print("Is Multiplayer: %s" % str(is_multiplayer_game))
	print("Local Player ID: %s" % local_player_id)
	print("Remote Player ID: %s" % remote_player_id)
	print("Is My Turn: %s" % str(is_my_turn))
	print("Is Connected: %s" % str(is_multiplayer_connected()))
	print("Connection Status: %s" % get_connection_status())
	print("Pending Events: %d" % pending_events.size())
	print("Has Remote Player Data: %s" % str(not remote_player_data.is_empty()))
	print("=================================")

# =============================================================================
# LEGACY COMPATIBILITY (for existing code)
# =============================================================================

# Legacy method - redirects to P2P
func create_server(port: int = 5000) -> bool:
	return start_p2p_server(port)

# Legacy method - redirects to P2P
func join_server(ip: String, port: int = 5000) -> bool:
	return connect_to_p2p_host(ip, port)

# Legacy method - redirects to unified disconnect
func disconnect_from_game() -> void:
	disconnect_multiplayer()

# Legacy method - sends event via unified system
func send_event(event_type: NetworkEvent.EventType, data: Dictionary = {}) -> void:
	var event := NetworkEvent.new(event_type, local_player_id)
	event.player_data = data
	send_network_event(event)

# Legacy method - ends turn via unified system
func end_turn() -> void:
	send_turn_end_signal()

# Legacy property getter
func is_online() -> bool:
	return is_multiplayer_game and is_multiplayer_connected()

# Legacy property getter
func get_my_id() -> int:
	if current_connection_type == ConnectionType.P2P_DIRECT:
		return p2p_connection.get_local_peer_id()
	return local_player_id.hash()

# Legacy property getter
func get_opponent_id() -> int:
	if current_connection_type == ConnectionType.P2P_DIRECT:
		return p2p_connection.get_remote_peer_id()
	return remote_player_id.hash()

# Legacy property getter
func is_opponent_connected() -> bool:
	return is_multiplayer_connected() and not remote_player_id.is_empty()

# Legacy property getter
func is_host() -> bool:
	match current_connection_type:
		ConnectionType.P2P_DIRECT:
			return p2p_connection.is_server
		ConnectionType.WEBRTC_MATCHMAKING:
			return webrtc_matchmaking.is_host
		_:
			return false

# Legacy property getter
func is_client() -> bool:
	return is_multiplayer_connected() and not is_host()
