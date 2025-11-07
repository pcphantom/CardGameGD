extends Control
class_name SettingsMenu

# Settings Menu
# Manages audio and network configuration
# Persists settings to user://settings.cfg

# UI References
@onready var master_volume_slider: HSlider = $CenterContainer/Panel/MarginContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/MasterVolumeContainer/ValueLabel
@onready var music_volume_slider: HSlider = $CenterContainer/Panel/MarginContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/MusicVolumeContainer/ValueLabel
@onready var sfx_volume_slider: HSlider = $CenterContainer/Panel/MarginContainer/VBoxContainer/SFXVolumeContainer/SFXVolumeSlider
@onready var sfx_volume_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/SFXVolumeContainer/ValueLabel
@onready var signaling_server_line_edit: LineEdit = $CenterContainer/Panel/MarginContainer/VBoxContainer/SignalingServerContainer/SignalingServerLineEdit
@onready var p2p_port_spin_box: SpinBox = $CenterContainer/Panel/MarginContainer/VBoxContainer/P2PPortContainer/P2PPortSpinBox
@onready var voice_chat_check_button: CheckButton = $CenterContainer/Panel/MarginContainer/VBoxContainer/VoiceChatContainer/VoiceChatCheckButton
@onready var save_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ButtonContainer/SaveButton
@onready var cancel_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ButtonContainer/CancelButton

# Settings file path
const SETTINGS_FILE: String = "user://settings.cfg"

# Default values
const DEFAULT_MASTER_VOLUME: float = 1.0
const DEFAULT_MUSIC_VOLUME: float = 0.7
const DEFAULT_SFX_VOLUME: float = 1.0
const DEFAULT_SIGNALING_URL: String = "ws://localhost:9080"
const DEFAULT_P2P_PORT: int = 5000
const DEFAULT_VOICE_CHAT: bool = false

# Settings state
var current_settings: Dictionary = {}
var original_settings: Dictionary = {}

# Signals
signal settings_saved()
signal settings_cancelled()

func _ready() -> void:
	print("SettingsMenu: Initializing")

	# Load existing settings
	_load_settings()

	# Store original settings for cancel functionality
	original_settings = current_settings.duplicate(true)

	# Apply settings to UI
	_apply_settings_to_ui()

	print("SettingsMenu: Ready")

# =============================================================================
# SETTINGS LOADING
# =============================================================================

# Load settings from config file
func _load_settings() -> void:
	print("SettingsMenu: Loading settings from %s" % SETTINGS_FILE)

	var config := ConfigFile.new()
	var err: Error = config.load(SETTINGS_FILE)

	if err != OK:
		print("SettingsMenu: No settings file found, using defaults")
		_load_default_settings()
		return

	# Load audio settings
	current_settings["master_volume"] = config.get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME)
	current_settings["music_volume"] = config.get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME)
	current_settings["sfx_volume"] = config.get_value("audio", "sfx_volume", DEFAULT_SFX_VOLUME)

	# Load network settings
	current_settings["signaling_url"] = config.get_value("network", "signaling_url", DEFAULT_SIGNALING_URL)
	current_settings["p2p_port"] = config.get_value("network", "p2p_port", DEFAULT_P2P_PORT)
	current_settings["voice_chat"] = config.get_value("network", "voice_chat", DEFAULT_VOICE_CHAT)

	print("SettingsMenu: Settings loaded successfully")
	_validate_settings()

# Load default settings
func _load_default_settings() -> void:
	current_settings = {
		"master_volume": DEFAULT_MASTER_VOLUME,
		"music_volume": DEFAULT_MUSIC_VOLUME,
		"sfx_volume": DEFAULT_SFX_VOLUME,
		"signaling_url": DEFAULT_SIGNALING_URL,
		"p2p_port": DEFAULT_P2P_PORT,
		"voice_chat": DEFAULT_VOICE_CHAT
	}

# Validate loaded settings
func _validate_settings() -> void:
	# Clamp volume values
	current_settings["master_volume"] = clampf(current_settings["master_volume"], 0.0, 1.0)
	current_settings["music_volume"] = clampf(current_settings["music_volume"], 0.0, 1.0)
	current_settings["sfx_volume"] = clampf(current_settings["sfx_volume"], 0.0, 1.0)

	# Validate port range
	current_settings["p2p_port"] = clampi(current_settings["p2p_port"], 1024, 65535)

	# Validate URL (basic check)
	if not _is_valid_websocket_url(current_settings["signaling_url"]):
		print("SettingsMenu: Invalid signaling URL, using default")
		current_settings["signaling_url"] = DEFAULT_SIGNALING_URL

# =============================================================================
# SETTINGS SAVING
# =============================================================================

# Save settings to config file
func _save_settings() -> void:
	print("SettingsMenu: Saving settings to %s" % SETTINGS_FILE)

	var config := ConfigFile.new()

	# Save audio settings
	config.set_value("audio", "master_volume", current_settings["master_volume"])
	config.set_value("audio", "music_volume", current_settings["music_volume"])
	config.set_value("audio", "sfx_volume", current_settings["sfx_volume"])

	# Save network settings
	config.set_value("network", "signaling_url", current_settings["signaling_url"])
	config.set_value("network", "p2p_port", current_settings["p2p_port"])
	config.set_value("network", "voice_chat", current_settings["voice_chat"])

	# Write to file
	var err: Error = config.save(SETTINGS_FILE)

	if err != OK:
		push_error("SettingsMenu: Failed to save settings. Error: %d" % err)
		return

	print("SettingsMenu: Settings saved successfully")

	# Apply settings to managers
	_apply_settings_to_managers()

# Apply settings to SoundManager and other managers
func _apply_settings_to_managers() -> void:
	print("SettingsMenu: Applying settings to managers")

	# Apply audio settings to SoundManager
	if SoundManager:
		SoundManager.set_master_volume(current_settings["master_volume"])
		SoundManager.set_music_volume(current_settings["music_volume"])
		SoundManager.set_sfx_volume(current_settings["sfx_volume"])
		print("SettingsMenu: Audio settings applied to SoundManager")

	# Apply network settings (WebRTC signaling URL would be used by WebRTCMatchmaking)
	# This would be read by the WebRTCMatchmaking class when it initializes
	# For now, we just store it for future use

	print("SettingsMenu: Settings applied to managers")

# =============================================================================
# UI UPDATES
# =============================================================================

# Apply current settings to UI controls
func _apply_settings_to_ui() -> void:
	# Audio sliders
	master_volume_slider.value = current_settings["master_volume"]
	music_volume_slider.value = current_settings["music_volume"]
	sfx_volume_slider.value = current_settings["sfx_volume"]

	# Update labels
	_update_volume_label(master_volume_label, current_settings["master_volume"])
	_update_volume_label(music_volume_label, current_settings["music_volume"])
	_update_volume_label(sfx_volume_label, current_settings["sfx_volume"])

	# Network settings
	signaling_server_line_edit.text = current_settings["signaling_url"]
	p2p_port_spin_box.value = current_settings["p2p_port"]
	voice_chat_check_button.button_pressed = current_settings["voice_chat"]

# Update volume label with percentage
func _update_volume_label(label: Label, value: float) -> void:
	label.text = "%d%%" % int(value * 100)

# =============================================================================
# SLIDER CALLBACKS
# =============================================================================

# Master volume changed
func _on_master_volume_changed(value: float) -> void:
	current_settings["master_volume"] = value
	_update_volume_label(master_volume_label, value)

	# Apply immediately for preview
	if SoundManager:
		SoundManager.set_master_volume(value)

	print("SettingsMenu: Master volume changed to %.2f" % value)

# Music volume changed
func _on_music_volume_changed(value: float) -> void:
	current_settings["music_volume"] = value
	_update_volume_label(music_volume_label, value)

	# Apply immediately for preview
	if SoundManager:
		SoundManager.set_music_volume(value)

	print("SettingsMenu: Music volume changed to %.2f" % value)

# SFX volume changed
func _on_sfx_volume_changed(value: float) -> void:
	current_settings["sfx_volume"] = value
	_update_volume_label(sfx_volume_label, value)

	# Apply immediately for preview
	if SoundManager:
		SoundManager.set_sfx_volume(value)

	print("SettingsMenu: SFX volume changed to %.2f" % value)

# =============================================================================
# NETWORK CALLBACKS
# =============================================================================

# Signaling server URL changed
func _on_signaling_url_changed(text: String) -> void:
	current_settings["signaling_url"] = text

	# Validate URL
	if _is_valid_websocket_url(text):
		signaling_server_line_edit.modulate = Color.WHITE
		print("SettingsMenu: Signaling URL changed to %s" % text)
	else:
		signaling_server_line_edit.modulate = Color(1.0, 0.5, 0.5)  # Light red
		print("SettingsMenu: Invalid signaling URL: %s" % text)

# P2P port changed
func _on_port_changed(value: float) -> void:
	var port: int = int(value)
	current_settings["p2p_port"] = port

	# Validate port range
	if port >= 1024 and port <= 65535:
		print("SettingsMenu: P2P port changed to %d" % port)
	else:
		push_warning("SettingsMenu: Port %d is out of valid range (1024-65535)" % port)

# Voice chat toggled
func _on_voice_chat_toggled(toggled_on: bool) -> void:
	current_settings["voice_chat"] = toggled_on
	print("SettingsMenu: Voice chat %s" % ("enabled" if toggled_on else "disabled"))

# =============================================================================
# BUTTON CALLBACKS
# =============================================================================

# Save button pressed
func _on_save_pressed() -> void:
	print("SettingsMenu: Save button pressed")

	# Validate settings before saving
	if not _is_valid_websocket_url(current_settings["signaling_url"]):
		_show_error_dialog("Invalid WebSocket URL", "Please enter a valid WebSocket URL (ws:// or wss://)")
		return

	# Save settings to file
	_save_settings()

	# Update original settings
	original_settings = current_settings.duplicate(true)

	# Emit signal
	settings_saved.emit()

	# Close menu
	queue_free()

# Cancel button pressed
func _on_cancel_pressed() -> void:
	print("SettingsMenu: Cancel button pressed")

	# Revert to original settings
	current_settings = original_settings.duplicate(true)

	# Reapply original settings to managers
	_apply_settings_to_managers()

	# Emit signal
	settings_cancelled.emit()

	# Close menu
	queue_free()

# =============================================================================
# VALIDATION
# =============================================================================

# Validate WebSocket URL format
func _is_valid_websocket_url(url: String) -> bool:
	if url.is_empty():
		return false

	# Check for ws:// or wss:// prefix
	if not (url.begins_with("ws://") or url.begins_with("wss://")):
		return false

	# Basic validation - should contain at least a host
	var without_protocol: String = url.substr(url.find("://") + 3)
	if without_protocol.is_empty():
		return false

	return true

# Validate port range
func _is_valid_port(port: int) -> bool:
	return port >= 1024 and port <= 65535

# =============================================================================
# UTILITY METHODS
# =============================================================================

# Show error dialog
func _show_error_dialog(title: String, message: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	add_child(dialog)
	dialog.popup_centered()

	# Auto-free after closing
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)

# Get current settings
func get_current_settings() -> Dictionary:
	return current_settings.duplicate(true)

# Reset to defaults
func reset_to_defaults() -> void:
	print("SettingsMenu: Resetting to defaults")
	_load_default_settings()
	_apply_settings_to_ui()
	_apply_settings_to_managers()

# =============================================================================
# STATIC METHODS (for external access)
# =============================================================================

# Load settings from file (static method for use by other scripts)
static func load_settings_static() -> Dictionary:
	var config := ConfigFile.new()
	var err: Error = config.load("user://settings.cfg")

	if err != OK:
		# Return defaults
		return {
			"master_volume": DEFAULT_MASTER_VOLUME,
			"music_volume": DEFAULT_MUSIC_VOLUME,
			"sfx_volume": DEFAULT_SFX_VOLUME,
			"signaling_url": DEFAULT_SIGNALING_URL,
			"p2p_port": DEFAULT_P2P_PORT,
			"voice_chat": DEFAULT_VOICE_CHAT
		}

	return {
		"master_volume": config.get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME),
		"music_volume": config.get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME),
		"sfx_volume": config.get_value("audio", "sfx_volume", DEFAULT_SFX_VOLUME),
		"signaling_url": config.get_value("network", "signaling_url", DEFAULT_SIGNALING_URL),
		"p2p_port": config.get_value("network", "p2p_port", DEFAULT_P2P_PORT),
		"voice_chat": config.get_value("network", "voice_chat", DEFAULT_VOICE_CHAT)
	}

# Apply loaded settings to managers (static method)
static func apply_settings_on_startup() -> void:
	var settings := load_settings_static()

	# Apply audio settings
	if SoundManager:
		SoundManager.set_master_volume(settings["master_volume"])
		SoundManager.set_music_volume(settings["music_volume"])
		SoundManager.set_sfx_volume(settings["sfx_volume"])
		print("SettingsMenu: Startup audio settings applied")

# =============================================================================
# DEBUG METHODS
# =============================================================================

# Print current settings
func print_settings() -> void:
	print("=== Current Settings ===")
	print("Master Volume: %.2f" % current_settings["master_volume"])
	print("Music Volume: %.2f" % current_settings["music_volume"])
	print("SFX Volume: %.2f" % current_settings["sfx_volume"])
	print("Signaling URL: %s" % current_settings["signaling_url"])
	print("P2P Port: %d" % current_settings["p2p_port"])
	print("Voice Chat: %s" % str(current_settings["voice_chat"]))
	print("========================")
