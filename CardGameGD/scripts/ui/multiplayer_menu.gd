extends Control
class_name MultiplayerMenu

# Multiplayer Menu UI
# Provides interface for all multiplayer connection options:
# - P2P Direct connections
# - WebRTC matchmaking
# - Private matches

# UI References
@onready var host_p2p_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/HostP2PButton
@onready var join_p2p_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/JoinP2PButton
@onready var find_match_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/FindMatchButton
@onready var create_private_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/CreatePrivateButton
@onready var join_private_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/JoinPrivateButton
@onready var host_match_line_edit: LineEdit = $CenterContainer/Panel/MarginContainer/VBoxContainer/HostMatchLineEdit
@onready var back_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/BackButton
@onready var status_dialog: AcceptDialog = $StatusDialog
@onready var match_id_dialog: AcceptDialog = $MatchIDDialog

# State
var is_connecting: bool = false
var connection_type: String = ""

# Signals
signal back_to_menu()
signal connection_started()
signal connection_established()

func _ready() -> void:
	print("MultiplayerMenu: Initializing")

	# Connect NetworkManager signals
	if NetworkManager:
		NetworkManager.multiplayer_connected.connect(_on_multiplayer_connected)
		NetworkManager.multiplayer_disconnected.connect(_on_multiplayer_disconnected)
		NetworkManager.opponent_info_received.connect(_on_opponent_info_received)
	else:
		push_error("MultiplayerMenu: NetworkManager not found!")

	print("MultiplayerMenu: Ready")

# =============================================================================
# P2P CONNECTION HANDLERS
# =============================================================================

# Host P2P game button pressed
func _on_host_p2p_pressed() -> void:
	print("MultiplayerMenu: Host P2P button pressed")

	if is_connecting:
		_show_status_dialog("Already connecting...", "Please wait")
		return

	# Start P2P server
	var success: bool = NetworkManager.start_p2p_server(5000)

	if success:
		is_connecting = true
		connection_type = "P2P_HOST"
		_disable_all_buttons()
		_show_status_dialog("Hosting P2P game on port 5000\n\nWaiting for opponent to connect...", "Hosting Game")
		connection_started.emit()
		print("MultiplayerMenu: P2P server started, waiting for opponent")
	else:
		_show_status_dialog("Failed to start P2P server.\nCheck if port 5000 is available.", "Connection Error")
		print("MultiplayerMenu: Failed to start P2P server")

# Join P2P game button pressed
func _on_join_p2p_pressed() -> void:
	print("MultiplayerMenu: Join P2P button pressed")

	if is_connecting:
		_show_status_dialog("Already connecting...", "Please wait")
		return

	# Get host address from input field
	var host: String = host_match_line_edit.text.strip_edges()

	if host.is_empty():
		_show_status_dialog("Please enter the host's IP address.\nExample: 192.168.1.100", "Input Required")
		return

	# Validate IP format (basic validation)
	if not _is_valid_ip_or_hostname(host):
		_show_status_dialog("Invalid IP address or hostname.\nPlease check your input.", "Invalid Input")
		return

	# Connect to P2P host
	var success: bool = NetworkManager.connect_to_p2p_host(host, 5000)

	if success:
		is_connecting = true
		connection_type = "P2P_CLIENT"
		_disable_all_buttons()
		_show_status_dialog("Connecting to %s:5000...\n\nPlease wait..." % host, "Connecting")
		connection_started.emit()
		print("MultiplayerMenu: Connecting to P2P host: %s" % host)
	else:
		_show_status_dialog("Failed to connect to host.\nCheck the IP address and try again.", "Connection Error")
		print("MultiplayerMenu: Failed to connect to P2P host")

# =============================================================================
# WEBRTC MATCHMAKING HANDLERS
# =============================================================================

# Find WebRTC match button pressed
func _on_find_match_pressed() -> void:
	print("MultiplayerMenu: Find match button pressed")

	if is_connecting:
		_show_status_dialog("Already connecting...", "Please wait")
		return

	# Start WebRTC matchmaking
	NetworkManager.start_webrtc_matchmaking()

	is_connecting = true
	connection_type = "WEBRTC_MATCHMAKING"
	_disable_all_buttons()
	_show_status_dialog("Searching for opponent online...\n\nThis may take a moment.", "Finding Match")
	connection_started.emit()
	print("MultiplayerMenu: WebRTC matchmaking started")

# Create private match button pressed
func _on_create_private_pressed() -> void:
	print("MultiplayerMenu: Create private match button pressed")

	if is_connecting:
		_show_status_dialog("Already connecting...", "Please wait")
		return

	# Create private WebRTC match
	var match_id: String = NetworkManager.create_private_webrtc_match()

	if not match_id.is_empty():
		is_connecting = true
		connection_type = "WEBRTC_PRIVATE_HOST"
		_disable_all_buttons()
		_show_match_id_dialog(match_id)
		connection_started.emit()
		print("MultiplayerMenu: Private match created with ID: %s" % match_id)
	else:
		_show_status_dialog("Failed to create private match.\nPlease try again.", "Connection Error")
		print("MultiplayerMenu: Failed to create private match")

# Join private match button pressed
func _on_join_private_pressed() -> void:
	print("MultiplayerMenu: Join private match button pressed")

	if is_connecting:
		_show_status_dialog("Already connecting...", "Please wait")
		return

	# Get match ID from input field
	var match_id: String = host_match_line_edit.text.strip_edges().to_upper()

	if match_id.is_empty():
		_show_status_dialog("Please enter the Match ID.\nYou should receive this from the host.", "Input Required")
		return

	# Validate match ID format (6 alphanumeric characters)
	if not _is_valid_match_id(match_id):
		_show_status_dialog("Invalid Match ID format.\nMatch ID should be 6 characters (e.g., MATCH1).", "Invalid Input")
		return

	# Join private WebRTC match
	var success: bool = NetworkManager.join_private_webrtc_match(match_id)

	if success:
		is_connecting = true
		connection_type = "WEBRTC_PRIVATE_CLIENT"
		_disable_all_buttons()
		_show_status_dialog("Joining private match: %s\n\nConnecting to host..." % match_id, "Joining Match")
		connection_started.emit()
		print("MultiplayerMenu: Joining private match: %s" % match_id)
	else:
		_show_status_dialog("Failed to join private match.\nCheck the Match ID and try again.", "Connection Error")
		print("MultiplayerMenu: Failed to join private match")

# =============================================================================
# BACK BUTTON HANDLER
# =============================================================================

# Back button pressed
func _on_back_pressed() -> void:
	print("MultiplayerMenu: Back button pressed")

	# If currently connecting, confirm disconnection
	if is_connecting:
		_show_status_dialog("Cancelling connection...", "Disconnecting")
		NetworkManager.disconnect_multiplayer()
		is_connecting = false
		connection_type = ""
		_enable_all_buttons()
		await get_tree().create_timer(0.5).timeout

	# Return to main menu
	back_to_menu.emit()
	queue_free()

# =============================================================================
# NETWORKMANGER SIGNAL HANDLERS
# =============================================================================

# Called when multiplayer connection succeeds
func _on_multiplayer_connected() -> void:
	print("MultiplayerMenu: Multiplayer connected!")

	is_connecting = false
	_show_status_dialog("Connected to opponent!\n\nStarting game...", "Success")
	connection_established.emit()

	# Wait a moment to show success message, then transition to game
	await get_tree().create_timer(1.5).timeout
	_transition_to_game()

# Called when multiplayer disconnects
func _on_multiplayer_disconnected() -> void:
	print("MultiplayerMenu: Multiplayer disconnected")

	if is_connecting:
		# Connection failed
		_show_status_dialog("Connection failed or opponent disconnected.\n\nPlease try again.", "Disconnected")
		is_connecting = false
		connection_type = ""
		_enable_all_buttons()
	else:
		# Normal disconnect (already in game or returning)
		pass

# Called when opponent info is received
func _on_opponent_info_received(player_data: Dictionary) -> void:
	print("MultiplayerMenu: Opponent info received: %s" % str(player_data))

	var opponent_name: String = player_data.get("name", "Unknown Player")
	var opponent_class: String = player_data.get("player_class", "Unknown")

	_show_status_dialog("Opponent found:\n%s (Class: %s)\n\nPreparing game..." % [opponent_name, opponent_class], "Opponent Found")

# =============================================================================
# UI HELPER METHODS
# =============================================================================

# Disable all connection buttons
func _disable_all_buttons() -> void:
	host_p2p_button.disabled = true
	join_p2p_button.disabled = true
	find_match_button.disabled = true
	create_private_button.disabled = true
	join_private_button.disabled = true
	host_match_line_edit.editable = false

# Enable all connection buttons
func _enable_all_buttons() -> void:
	host_p2p_button.disabled = false
	join_p2p_button.disabled = false
	find_match_button.disabled = false
	create_private_button.disabled = false
	join_private_button.disabled = false
	host_match_line_edit.editable = true

# Show status dialog with message
func _show_status_dialog(message: String, title: String = "Status") -> void:
	status_dialog.dialog_text = message
	status_dialog.title = title
	status_dialog.popup_centered()

# Show match ID dialog
func _show_match_id_dialog(match_id: String) -> void:
	var message: String = "Private Match Created!\n\nMatch ID: %s\n\nShare this ID with your friend to join.\n\nWaiting for opponent..." % match_id
	match_id_dialog.dialog_text = message
	match_id_dialog.title = "Match ID - Share This"
	match_id_dialog.popup_centered()

# =============================================================================
# VALIDATION METHODS
# =============================================================================

# Validate IP address or hostname
func _is_valid_ip_or_hostname(input: String) -> bool:
	# Check for localhost
	if input == "localhost" or input == "127.0.0.1":
		return true

	# Check for valid IPv4 format (basic validation)
	var parts: PackedStringArray = input.split(".")
	if parts.size() == 4:
		for part in parts:
			if not part.is_valid_int():
				# Could be hostname
				return input.length() > 0 and input.length() < 256
			var num: int = part.to_int()
			if num < 0 or num > 255:
				return false
		return true

	# Check if it's a valid hostname (basic check)
	if input.length() > 0 and input.length() < 256:
		# Hostname should contain only alphanumeric, dots, and hyphens
		var regex := RegEx.new()
		regex.compile("^[a-zA-Z0-9.-]+$")
		return regex.search(input) != null

	return false

# Validate match ID format
func _is_valid_match_id(match_id: String) -> bool:
	# Match ID should be 6 alphanumeric characters
	if match_id.length() != 6:
		return false

	var regex := RegEx.new()
	regex.compile("^[A-Z0-9]{6}$")
	return regex.search(match_id) != null

# =============================================================================
# TRANSITION METHODS
# =============================================================================

# Transition to game scene
func _transition_to_game() -> void:
	print("MultiplayerMenu: Transitioning to game")

	# Check if game scene exists
	if ResourceLoader.exists("res://scenes/game/game_scene.tscn"):
		get_tree().change_scene_to_file("res://scenes/game/game_scene.tscn")
	else:
		# For now, just show a message
		_show_status_dialog("Game scene not yet implemented.\n\nMultiplayer connection established successfully!", "Success")
		print("MultiplayerMenu: Game scene not found, staying in menu")

# =============================================================================
# DEBUG METHODS
# =============================================================================

# Print debug info
func print_debug_info() -> void:
	print("=== MultiplayerMenu Debug Info ===")
	print("Is Connecting: %s" % str(is_connecting))
	print("Connection Type: %s" % connection_type)
	print("NetworkManager Connected: %s" % str(NetworkManager.is_multiplayer_connected()))
	print("Input Text: %s" % host_match_line_edit.text)
	print("==================================")
