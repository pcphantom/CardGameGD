extends Control
class_name ServerBrowser

# Server Browser for LAN Discovery
# Uses UDP broadcasting to discover local P2P game servers
# Port 4446 for broadcasts (matching original libGDX implementation)

# Constants
const BROADCAST_PORT: int = 4446
const BROADCAST_INTERVAL: float = 2.0  # Seconds between broadcasts
const SERVER_TIMEOUT: float = 10.0  # Seconds before server is considered offline
const BROADCAST_MESSAGE: String = "CARD_GAME_SERVER_DISCOVER"
const RESPONSE_MESSAGE: String = "CARD_GAME_SERVER_RESPONSE"

# UDP Socket
var udp_socket: PacketPeerUDP = null
var is_server_mode: bool = false
var is_listening: bool = false

# Server info
var local_server_name: String = ""
var local_server_port: int = 5000

# Discovered servers
var discovered_servers: Dictionary = {}  # IP -> ServerInfo

# Timer
var broadcast_timer: float = 0.0
var cleanup_timer: float = 0.0

# UI References (to be set externally or via exported variables)
var server_list_container: VBoxContainer = null

# Signals
signal server_discovered(server_info: Dictionary)
signal server_removed(server_ip: String)
signal connect_to_server_requested(server_ip: String)

# Server info structure
class ServerInfo:
	var ip: String = ""
	var port: int = 5000
	var host_name: String = ""
	var last_seen: float = 0.0
	var player_count: int = 0

	func _init(p_ip: String, p_port: int, p_host_name: String):
		ip = p_ip
		port = p_port
		host_name = p_host_name
		last_seen = Time.get_ticks_msec() / 1000.0

	func update_last_seen() -> void:
		last_seen = Time.get_ticks_msec() / 1000.0

	func is_expired() -> bool:
		var current_time: float = Time.get_ticks_msec() / 1000.0
		return (current_time - last_seen) > SERVER_TIMEOUT

	func to_dict() -> Dictionary:
		return {
			"ip": ip,
			"port": port,
			"host_name": host_name,
			"last_seen": last_seen,
			"player_count": player_count
		}

func _ready() -> void:
	print("ServerBrowser: Initializing")

func _process(delta: float) -> void:
	if not is_listening:
		return

	# Handle broadcast timer (server mode)
	if is_server_mode:
		broadcast_timer += delta
		if broadcast_timer >= BROADCAST_INTERVAL:
			broadcast_timer = 0.0
			_send_server_presence()

	# Handle cleanup timer (client mode)
	if not is_server_mode:
		cleanup_timer += delta
		if cleanup_timer >= 2.0:  # Check every 2 seconds
			cleanup_timer = 0.0
			_cleanup_expired_servers()

	# Poll for incoming messages
	if udp_socket:
		_poll_udp_socket()

# =============================================================================
# SERVER MODE - Broadcasting Presence
# =============================================================================

# Start broadcasting server presence
func broadcast_server_presence(server_name: String, port: int = 5000) -> bool:
	print("ServerBrowser: Starting server broadcast mode")

	local_server_name = server_name
	local_server_port = port
	is_server_mode = true

	# Create UDP socket
	udp_socket = PacketPeerUDP.new()

	# Enable broadcast mode
	udp_socket.set_broadcast_enabled(true)

	# Bind to a port for receiving discovery requests
	var error: Error = udp_socket.bind(BROADCAST_PORT)

	if error != OK:
		push_error("ServerBrowser: Failed to bind to port %d for broadcasts. Error: %d" % [BROADCAST_PORT, error])
		udp_socket = null
		return false

	is_listening = true
	print("ServerBrowser: Server broadcast mode started on port %d" % BROADCAST_PORT)
	print("ServerBrowser: Broadcasting as '%s' on port %d" % [server_name, port])

	# Send initial broadcast
	_send_server_presence()

	return true

# Send server presence broadcast
func _send_server_presence() -> void:
	if not udp_socket or not is_server_mode:
		return

	# Prepare response message
	var message: Dictionary = {
		"type": RESPONSE_MESSAGE,
		"host_name": local_server_name,
		"port": local_server_port,
		"player_count": 0  # Could be updated based on actual player count
	}

	var json_string: String = JSON.stringify(message)
	var packet: PackedByteArray = json_string.to_utf8_buffer()

	# Send to broadcast address
	var error: Error = udp_socket.set_dest_address("255.255.255.255", BROADCAST_PORT)

	if error != OK:
		push_error("ServerBrowser: Failed to set broadcast destination. Error: %d" % error)
		return

	error = udp_socket.put_packet(packet)

	if error != OK:
		push_error("ServerBrowser: Failed to send broadcast packet. Error: %d" % error)
		return

	print("ServerBrowser: Broadcast sent - %s" % local_server_name)

# =============================================================================
# CLIENT MODE - Listening for Servers
# =============================================================================

# Start listening for server broadcasts
func listen_for_servers() -> bool:
	print("ServerBrowser: Starting client listening mode")

	is_server_mode = false

	# Create UDP socket
	udp_socket = PacketPeerUDP.new()

	# Enable broadcast mode
	udp_socket.set_broadcast_enabled(true)

	# Bind to broadcast port
	var error: Error = udp_socket.bind(BROADCAST_PORT)

	if error != OK:
		push_error("ServerBrowser: Failed to bind to port %d for listening. Error: %d" % [BROADCAST_PORT, error])
		udp_socket = null
		return false

	is_listening = true
	print("ServerBrowser: Client listening mode started on port %d" % BROADCAST_PORT)

	# Send initial discovery request
	_send_discovery_request()

	return true

# Send discovery request
func _send_discovery_request() -> void:
	if not udp_socket:
		return

	# Prepare discovery message
	var message: Dictionary = {
		"type": BROADCAST_MESSAGE
	}

	var json_string: String = JSON.stringify(message)
	var packet: PackedByteArray = json_string.to_utf8_buffer()

	# Send to broadcast address
	var error: Error = udp_socket.set_dest_address("255.255.255.255", BROADCAST_PORT)

	if error != OK:
		push_error("ServerBrowser: Failed to set broadcast destination. Error: %d" % error)
		return

	error = udp_socket.put_packet(packet)

	if error != OK:
		push_error("ServerBrowser: Failed to send discovery packet. Error: %d" % error)
		return

	print("ServerBrowser: Discovery request sent")

# =============================================================================
# UDP MESSAGE HANDLING
# =============================================================================

# Poll UDP socket for incoming messages
func _poll_udp_socket() -> void:
	if not udp_socket:
		return

	while udp_socket.get_available_packet_count() > 0:
		var packet: PackedByteArray = udp_socket.get_packet()
		var sender_ip: String = udp_socket.get_packet_ip()
		var sender_port: int = udp_socket.get_packet_port()

		# Parse message
		var message_str: String = packet.get_string_from_utf8()
		_handle_message(message_str, sender_ip, sender_port)

# Handle received message
func _handle_message(message_str: String, sender_ip: String, sender_port: int) -> void:
	# Parse JSON
	var json := JSON.new()
	var parse_result: Error = json.parse(message_str)

	if parse_result != OK:
		push_warning("ServerBrowser: Failed to parse message from %s: %s" % [sender_ip, message_str])
		return

	var message: Dictionary = json.data

	if not message.has("type"):
		push_warning("ServerBrowser: Message from %s missing 'type' field" % sender_ip)
		return

	var msg_type: String = message.get("type", "")

	match msg_type:
		BROADCAST_MESSAGE:
			# Discovery request received (server mode)
			if is_server_mode:
				print("ServerBrowser: Discovery request from %s" % sender_ip)
				_send_server_presence()

		RESPONSE_MESSAGE:
			# Server response received (client mode)
			if not is_server_mode:
				_handle_server_response(message, sender_ip)

		_:
			push_warning("ServerBrowser: Unknown message type: %s" % msg_type)

# Handle server response
func _handle_server_response(message: Dictionary, sender_ip: String) -> void:
	var host_name: String = message.get("host_name", "Unknown Server")
	var port: int = message.get("port", 5000)
	var player_count: int = message.get("player_count", 0)

	print("ServerBrowser: Server discovered - %s (%s:%d)" % [host_name, sender_ip, port])

	# Check if server already exists
	if discovered_servers.has(sender_ip):
		# Update existing server
		var server_info: ServerInfo = discovered_servers[sender_ip]
		server_info.update_last_seen()
		server_info.player_count = player_count
	else:
		# Add new server
		var server_info := ServerInfo.new(sender_ip, port, host_name)
		server_info.player_count = player_count
		discovered_servers[sender_ip] = server_info

		# Emit signal
		server_discovered.emit(server_info.to_dict())

		# Update UI if available
		_update_server_list_ui()

# =============================================================================
# SERVER LIST MANAGEMENT
# =============================================================================

# Cleanup expired servers
func _cleanup_expired_servers() -> void:
	var expired_servers: Array = []

	# Find expired servers
	for ip in discovered_servers.keys():
		var server_info: ServerInfo = discovered_servers[ip]
		if server_info.is_expired():
			expired_servers.append(ip)

	# Remove expired servers
	for ip in expired_servers:
		print("ServerBrowser: Server %s timed out" % ip)
		discovered_servers.erase(ip)
		server_removed.emit(ip)

	# Update UI if servers were removed
	if expired_servers.size() > 0:
		_update_server_list_ui()

# Get list of discovered servers
func get_discovered_servers() -> Array:
	var servers: Array = []

	for server_info in discovered_servers.values():
		servers.append(server_info.to_dict())

	return servers

# Clear all discovered servers
func clear_servers() -> void:
	discovered_servers.clear()
	_update_server_list_ui()

# =============================================================================
# UI MANAGEMENT
# =============================================================================

# Set server list container for UI updates
func set_server_list_container(container: VBoxContainer) -> void:
	server_list_container = container
	_update_server_list_ui()

# Update server list UI
func _update_server_list_ui() -> void:
	if not server_list_container:
		return

	# Clear existing entries
	for child in server_list_container.get_children():
		child.queue_free()

	# Add server entries
	for server_info in discovered_servers.values():
		_add_server_entry_to_ui(server_info)

	# Show "no servers" message if empty
	if discovered_servers.is_empty():
		var label := Label.new()
		label.text = "No servers found. Make sure a host is running on your local network."
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		server_list_container.add_child(label)

# Add server entry to UI
func _add_server_entry_to_ui(server_info: ServerInfo) -> void:
	if not server_list_container:
		return

	# Create container for server entry
	var entry_container := HBoxContainer.new()
	entry_container.custom_minimum_size = Vector2(0, 50)

	# Server info label
	var info_label := Label.new()
	info_label.text = "%s (%s:%d)" % [server_info.host_name, server_info.ip, server_info.port]
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entry_container.add_child(info_label)

	# Connect button
	var connect_button := Button.new()
	connect_button.text = "Connect"
	connect_button.custom_minimum_size = Vector2(100, 0)
	connect_button.pressed.connect(_on_connect_button_pressed.bind(server_info.ip, server_info.port))
	entry_container.add_child(connect_button)

	# Add separator
	var separator := HSeparator.new()
	server_list_container.add_child(separator)

	server_list_container.add_child(entry_container)

# Connect button pressed
func _on_connect_button_pressed(server_ip: String, server_port: int) -> void:
	print("ServerBrowser: Connect to server requested - %s:%d" % [server_ip, server_port])
	connect_to_server_requested.emit(server_ip)

# =============================================================================
# CLEANUP
# =============================================================================

# Stop broadcasting/listening
func stop() -> void:
	print("ServerBrowser: Stopping")

	is_listening = false
	is_server_mode = false

	if udp_socket:
		udp_socket.close()
		udp_socket = null

	discovered_servers.clear()
	_update_server_list_ui()

	print("ServerBrowser: Stopped")

# Cleanup on exit
func _exit_tree() -> void:
	stop()

# =============================================================================
# DEBUG METHODS
# =============================================================================

# Print debug info
func print_debug_info() -> void:
	print("=== ServerBrowser Debug Info ===")
	print("Is Server Mode: %s" % str(is_server_mode))
	print("Is Listening: %s" % str(is_listening))
	print("Local Server Name: %s" % local_server_name)
	print("Local Server Port: %d" % local_server_port)
	print("Discovered Servers: %d" % discovered_servers.size())

	for ip in discovered_servers.keys():
		var server_info: ServerInfo = discovered_servers[ip]
		print("  - %s (%s:%d) - Last seen: %.1fs ago" % [
			server_info.host_name,
			server_info.ip,
			server_info.port,
			(Time.get_ticks_msec() / 1000.0) - server_info.last_seen
		])

	print("================================")

# Test broadcast (for debugging)
func test_broadcast() -> void:
	print("ServerBrowser: Testing broadcast")

	if is_server_mode:
		_send_server_presence()
	else:
		_send_discovery_request()

# Refresh server list (manually)
func refresh_server_list() -> void:
	print("ServerBrowser: Refreshing server list")

	if not is_server_mode:
		_send_discovery_request()
