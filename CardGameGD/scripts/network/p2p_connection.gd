extends Node
class_name P2PConnection

# P2P Connection system for direct player-to-player multiplayer
# Uses Godot's ENetMultiplayerPeer for low-latency 1v1 matches

# Constants
const DEFAULT_PORT: int = 5000
const MAX_CLIENTS: int = 2  # 1v1 game

# Properties
var peer: ENetMultiplayerPeer = null
var is_server: bool = false
var is_connected: bool = false
var remote_player_id: int = -1

# Signals
signal connection_succeeded()
signal connection_failed()
signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal received_player_info(player_data: Dictionary)
signal received_event(event: NetworkEvent)

func _ready() -> void:
	# Connect to multiplayer signals
	if multiplayer.has_signal("peer_connected"):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if multiplayer.has_signal("peer_disconnected"):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if multiplayer.has_signal("connected_to_server"):
		multiplayer.connected_to_server.connect(_on_connection_succeeded)
	if multiplayer.has_signal("connection_failed"):
		multiplayer.connection_failed.connect(_on_connection_failed)
	if multiplayer.has_signal("server_disconnected"):
		multiplayer.server_disconnected.connect(_on_server_disconnected)

# Create server for hosting a game
func create_server(port: int = DEFAULT_PORT) -> bool:
	print("P2PConnection: Creating server on port %d" % port)

	# Create new ENet peer
	peer = ENetMultiplayerPeer.new()

	# Create server with compression enabled
	var result: Error = peer.create_server(port, MAX_CLIENTS)

	if result != OK:
		push_error("P2PConnection: Failed to create server on port %d. Error: %d" % [port, result])
		peer = null
		return false

	# Configure peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	# Set as the multiplayer peer
	multiplayer.multiplayer_peer = peer

	# Mark as server
	is_server = true
	is_connected = true

	print("P2PConnection: Server created successfully on port %d" % port)
	print("P2PConnection: Server peer ID: %d" % multiplayer.get_unique_id())

	return true

# Connect to server as client
func connect_to_server(host: String, port: int = DEFAULT_PORT) -> bool:
	print("P2PConnection: Connecting to server at %s:%d" % [host, port])

	# Create new ENet peer
	peer = ENetMultiplayerPeer.new()

	# Connect to server with compression enabled
	var result: Error = peer.create_client(host, port)

	if result != OK:
		push_error("P2PConnection: Failed to connect to %s:%d. Error: %d" % [host, port, result])
		peer = null
		return false

	# Configure peer
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	# Set as the multiplayer peer
	multiplayer.multiplayer_peer = peer

	# Mark as client
	is_server = false

	print("P2PConnection: Connection initiated to %s:%d" % [host, port])

	return true

# Send network event to remote peer
func send_event(event: NetworkEvent) -> void:
	if not is_connected:
		push_warning("P2PConnection: Cannot send event - not connected")
		return

	if event == null:
		push_warning("P2PConnection: Cannot send null event")
		return

	# Convert event to dictionary
	var event_data: Dictionary = event.to_dict()

	# Send to remote peer via RPC
	if is_server:
		# Server sends to specific client
		if remote_player_id > 0:
			rpc_id(remote_player_id, "receive_event", event_data)
		else:
			push_warning("P2PConnection: No remote player connected to send event to")
	else:
		# Client sends to server (peer ID 1)
		rpc_id(1, "receive_event", event_data)

# Receive network event from remote peer
@rpc("any_peer", "call_remote", "reliable")
func receive_event(event_data: Dictionary) -> void:
	# Validate sender
	var sender_id: int = multiplayer.get_remote_sender_id()

	if not is_valid_peer(sender_id):
		push_warning("P2PConnection: Received event from invalid peer %d" % sender_id)
		return

	# Convert dictionary to NetworkEvent
	var event: NetworkEvent = NetworkEvent.from_dict(event_data)

	if event == null:
		push_warning("P2PConnection: Failed to deserialize network event")
		return

	# Handle different event types
	match event.get_event_type():
		NetworkEvent.EventType.REMOTE_PLAYER_INFO_INIT:
			# Player info initialization
			received_player_info.emit(event.get_player_data())
		_:
			# Emit generic event signal for game logic to handle
			received_event.emit(event)

# Send player info to remote peer
func send_player_info(player_data: Dictionary) -> void:
	if not is_connected:
		push_warning("P2PConnection: Cannot send player info - not connected")
		return

	var event := NetworkEvent.create_with_player(NetworkEvent.EventType.REMOTE_PLAYER_INFO_INIT, player_data)
	send_event(event)

# Get remote peer ID
func get_remote_peer_id() -> int:
	return remote_player_id

# Check if this peer is the multiplayer server/authority
func is_server_peer() -> bool:
	return multiplayer.is_server()

# Disconnect from current game
func disconnect_from_game() -> void:
	print("P2PConnection: Disconnecting from game")

	if peer != null:
		peer.close()
		peer = null

	multiplayer.multiplayer_peer = null

	is_server = false
	is_connected = false
	remote_player_id = -1

	print("P2PConnection: Disconnected")

# Check if peer ID is valid
func is_valid_peer(peer_id: int) -> bool:
	if is_server:
		# Server accepts from connected client
		return peer_id == remote_player_id
	else:
		# Client accepts from server (peer ID 1)
		return peer_id == 1

# Get connection status string
func get_connection_status() -> String:
	if not is_connected:
		return "Disconnected"
	elif is_server:
		return "Server (Port: %d)" % DEFAULT_PORT if peer != null else "Server"
	else:
		return "Client (Connected)"

# Get number of connected peers
func get_connected_peer_count() -> int:
	if not is_connected:
		return 0

	if peer == null:
		return 0

	# Count connected peers
	var peers: Array = multiplayer.get_peers()
	return peers.size()

# Signal handlers
func _on_peer_connected(peer_id: int) -> void:
	print("P2PConnection: Peer connected: %d" % peer_id)

	# Store remote player ID
	if remote_player_id == -1:
		remote_player_id = peer_id
		is_connected = true
		print("P2PConnection: Remote player ID set to %d" % peer_id)

	# Emit signal
	player_connected.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	print("P2PConnection: Peer disconnected: %d" % peer_id)

	# Clear remote player ID if it was this peer
	if remote_player_id == peer_id:
		remote_player_id = -1
		is_connected = false
		print("P2PConnection: Remote player disconnected")

	# Emit signal
	player_disconnected.emit(peer_id)

func _on_connection_succeeded() -> void:
	print("P2PConnection: Connection succeeded")

	# For clients, store server as remote player
	if not is_server:
		remote_player_id = 1  # Server is always peer ID 1
		is_connected = true

	# Emit signal
	connection_succeeded.emit()

func _on_connection_failed() -> void:
	print("P2PConnection: Connection failed")

	# Clean up
	if peer != null:
		peer.close()
		peer = null

	multiplayer.multiplayer_peer = null
	is_connected = false
	remote_player_id = -1

	# Emit signal
	connection_failed.emit()

func _on_server_disconnected() -> void:
	print("P2PConnection: Server disconnected")

	# Clean up client connection
	if peer != null:
		peer.close()
		peer = null

	multiplayer.multiplayer_peer = null
	is_connected = false
	remote_player_id = -1

	# Emit as player disconnected signal
	player_disconnected.emit(1)

# Get local peer ID
func get_local_peer_id() -> int:
	return multiplayer.get_unique_id()

# Check if currently hosting
func is_hosting() -> bool:
	return is_server and is_connected

# Check if currently connected as client
func is_client_connected() -> bool:
	return not is_server and is_connected

# Get peer info
func get_peer_info() -> Dictionary:
	return {
		"local_peer_id": get_local_peer_id(),
		"remote_peer_id": remote_player_id,
		"is_server": is_server,
		"is_connected": is_connected,
		"connection_status": get_connection_status(),
		"peer_count": get_connected_peer_count()
	}

# Print connection debug info
func print_debug_info() -> void:
	print("=== P2P Connection Debug Info ===")
	print("Local Peer ID: %d" % get_local_peer_id())
	print("Remote Peer ID: %d" % remote_player_id)
	print("Is Server: %s" % str(is_server))
	print("Is Connected: %s" % str(is_connected))
	print("Connection Status: %s" % get_connection_status())
	print("Peer Count: %d" % get_connected_peer_count())
	print("================================")
