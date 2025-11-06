extends Control
class_name MainMenu

# Main Menu
# Entry point for the game - provides access to all game modes and settings

# UI References
@onready var single_player_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/SinglePlayerButton
@onready var multiplayer_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/MultiplayerButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/SettingsButton
@onready var how_to_play_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/HowToPlayButton
@onready var credits_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/CreditsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/ButtonsContainer/QuitButton
@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var game_logo: TextureRect = $CenterContainer/VBoxContainer/TitleContainer/GameLogo
@onready var version_label: Label = $CenterContainer/VBoxContainer/VersionLabel

# Scene paths
const GAME_SCENE_PATH: String = "res://scenes/game/game_scene.tscn"
const MULTIPLAYER_MENU_SCENE_PATH: String = "res://scenes/ui/multiplayer_menu.tscn"
const SETTINGS_MENU_SCENE_PATH: String = "res://scenes/ui/settings_menu.tscn"

# Scene references (loaded on demand)
var multiplayer_menu_scene: PackedScene = null
var settings_menu_scene: PackedScene = null
var game_scene: PackedScene = null

# State
var is_transitioning: bool = false
var active_submenu: Control = null

# Fade transition settings
const FADE_DURATION: float = 0.3
const FADE_COLOR: Color = Color.BLACK

# Signals
signal menu_exited()

func _ready() -> void:
	print("MainMenu: Initializing")

	# Start background music
	if SoundManager:
		SoundManager.start_background_music()
		print("MainMenu: Background music started")

	# Apply saved settings on startup
	SettingsMenu.apply_settings_on_startup()

	# Set version from project settings
	_update_version_label()

	# Fade in from black
	_fade_in()

	# Add hover effects to buttons
	_setup_button_hover_effects()

	print("MainMenu: Ready")

# =============================================================================
# INITIALIZATION
# =============================================================================

# Update version label from project settings
func _update_version_label() -> void:
	var version: String = ProjectSettings.get_setting("application/config/version", "1.0.0")
	var engine_version: String = Engine.get_version_info()["string"]
	version_label.text = "Version %s - Godot %s" % [version, engine_version]

# Setup hover effects for all buttons
func _setup_button_hover_effects() -> void:
	var buttons: Array[Button] = [
		single_player_button,
		multiplayer_button,
		settings_button,
		how_to_play_button,
		credits_button,
		quit_button
	]

	for button in buttons:
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover.bind(button))

# =============================================================================
# BUTTON CALLBACKS
# =============================================================================

# Single Player button pressed
func _on_single_player_pressed() -> void:
	print("MainMenu: Single Player selected")

	if is_transitioning:
		return

	# Play button sound
	if SoundManager:
		SoundManager.play_sound_by_enum(SoundManager.Sound.POSITIVE_EFFECT)

	# Disable all buttons
	_disable_all_buttons()

	# Fade out and load game scene
	await _fade_out()
	_load_game_scene()

# Multiplayer button pressed
func _on_multiplayer_pressed() -> void:
	print("MainMenu: Multiplayer selected")

	if is_transitioning:
		return

	# Play button sound
	if SoundManager:
		SoundManager.play_sound_by_enum(SoundManager.Sound.POSITIVE_EFFECT)

	# Show multiplayer menu
	_show_multiplayer_menu()

# Settings button pressed
func _on_settings_pressed() -> void:
	print("MainMenu: Settings selected")

	if is_transitioning:
		return

	# Play button sound
	if SoundManager:
		SoundManager.play_sound_by_enum(SoundManager.Sound.POSITIVE_EFFECT)

	# Show settings menu
	_show_settings_menu()

# How to Play button pressed
func _on_how_to_play_pressed() -> void:
	print("MainMenu: How to Play selected")

	if is_transitioning:
		return

	# Play button sound
	if SoundManager:
		SoundManager.play_sound_by_enum(SoundManager.Sound.POSITIVE_EFFECT)

	# Show tutorial/instructions
	_show_how_to_play()

# Credits button pressed
func _on_credits_pressed() -> void:
	print("MainMenu: Credits selected")

	if is_transitioning:
		return

	# Play button sound
	if SoundManager:
		SoundManager.play_sound_by_enum(SoundManager.Sound.POSITIVE_EFFECT)

	# Show credits screen
	_show_credits()

# Quit button pressed
func _on_quit_pressed() -> void:
	print("MainMenu: Quit selected")

	if is_transitioning:
		return

	# Play button sound
	if SoundManager:
		SoundManager.play_sound_by_enum(SoundManager.Sound.NEGATIVE_EFFECT)

	# Show quit confirmation
	_show_quit_confirmation()

# =============================================================================
# BUTTON HOVER EFFECTS
# =============================================================================

# Button hover entered
func _on_button_hover(button: Button) -> void:
	# Scale up slightly
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)

# Button hover exited
func _on_button_unhover(button: Button) -> void:
	# Scale back to normal
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

# =============================================================================
# SCENE LOADING
# =============================================================================

# Load single player game scene
func _load_game_scene() -> void:
	print("MainMenu: Loading game scene")

	# Check if scene exists
	if not ResourceLoader.exists(GAME_SCENE_PATH):
		push_error("MainMenu: Game scene not found at %s" % GAME_SCENE_PATH)
		_show_error_dialog("Error", "Game scene not found. Please check installation.")
		_fade_in()
		_enable_all_buttons()
		return

	# Load and change to game scene
	var error: Error = get_tree().change_scene_to_file(GAME_SCENE_PATH)

	if error != OK:
		push_error("MainMenu: Failed to load game scene. Error: %d" % error)
		_show_error_dialog("Error", "Failed to load game scene.")
		_fade_in()
		_enable_all_buttons()

# =============================================================================
# SUBMENU MANAGEMENT
# =============================================================================

# Show multiplayer menu
func _show_multiplayer_menu() -> void:
	print("MainMenu: Showing multiplayer menu")

	# Load scene if not already loaded
	if multiplayer_menu_scene == null:
		if ResourceLoader.exists(MULTIPLAYER_MENU_SCENE_PATH):
			multiplayer_menu_scene = load(MULTIPLAYER_MENU_SCENE_PATH)
		else:
			push_error("MainMenu: Multiplayer menu scene not found")
			_show_error_dialog("Error", "Multiplayer menu not found.")
			return

	# Instantiate and add to scene
	var menu_instance: Control = multiplayer_menu_scene.instantiate()
	add_child(menu_instance)
	active_submenu = menu_instance

	# Connect back signal
	if menu_instance.has_signal("back_to_menu"):
		menu_instance.back_to_menu.connect(_on_submenu_closed)

	print("MainMenu: Multiplayer menu shown")

# Show settings menu
func _show_settings_menu() -> void:
	print("MainMenu: Showing settings menu")

	# Load scene if not already loaded
	if settings_menu_scene == null:
		if ResourceLoader.exists(SETTINGS_MENU_SCENE_PATH):
			settings_menu_scene = load(SETTINGS_MENU_SCENE_PATH)
		else:
			push_error("MainMenu: Settings menu scene not found")
			_show_error_dialog("Error", "Settings menu not found.")
			return

	# Instantiate and add to scene
	var menu_instance: Control = settings_menu_scene.instantiate()
	add_child(menu_instance)
	active_submenu = menu_instance

	# Connect signals
	if menu_instance.has_signal("settings_saved"):
		menu_instance.settings_saved.connect(_on_submenu_closed)
	if menu_instance.has_signal("settings_cancelled"):
		menu_instance.settings_cancelled.connect(_on_submenu_closed)

	print("MainMenu: Settings menu shown")

# Submenu closed
func _on_submenu_closed() -> void:
	print("MainMenu: Submenu closed")
	active_submenu = null

# =============================================================================
# HOW TO PLAY DIALOG
# =============================================================================

# Show How to Play dialog
func _show_how_to_play() -> void:
	print("MainMenu: Showing How to Play")

	var dialog := AcceptDialog.new()
	dialog.title = "How to Play"
	dialog.dialog_text = """Welcome to Card Game!

OBJECTIVE:
Reduce your opponent's life to 0 to win the game.

GAMEPLAY:
• Each turn, you gain resources of each type
• Use resources to summon creatures and cast spells
• Creatures attack the opponent each turn
• End your turn to let your opponent play

CARD TYPES:
• Creatures: Attack your opponent automatically
• Spells: Cast for immediate effects

RESOURCES:
🔥 Fire - Aggressive creatures and damage spells
💧 Water - Defensive creatures and healing
💨 Air - Fast creatures and draw effects
🪨 Earth - Strong creatures and buffs
✨ Other - Utility and special effects

TIPS:
• Balance your deck with creatures and spells
• Manage your resources carefully
• Consider card synergies
• Watch your opponent's strategy

Good luck, and have fun!"""

	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	dialog.size = Vector2i(600, 500)
	add_child(dialog)
	dialog.popup_centered()

	# Auto-free after closing
	dialog.confirmed.connect(dialog.queue_free)

# =============================================================================
# CREDITS DIALOG
# =============================================================================

# Show Credits dialog
func _show_credits() -> void:
	print("MainMenu: Showing Credits")

	var dialog := AcceptDialog.new()
	dialog.title = "Credits"
	dialog.dialog_text = """Card Game - Godot Edition

ORIGINAL GAME:
libGDX Card Game by Antinori

GODOT CONVERSION:
Phase 7: Complete Multiplayer Integration
- Network System (P2P & WebRTC)
- Sound System
- Visual Polish
- Settings & Configuration

POWERED BY:
• Godot Engine 4.5.1
• GDScript

SPECIAL THANKS:
• The Godot community
• Original libGDX developers
• All playtesters

MUSIC & SOUND:
• Background music and sound effects

Made with ❤️ using Godot Engine

Version 1.0.0 - 2024"""

	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	dialog.size = Vector2i(500, 500)
	add_child(dialog)
	dialog.popup_centered()

	# Auto-free after closing
	dialog.confirmed.connect(dialog.queue_free)

# =============================================================================
# QUIT CONFIRMATION
# =============================================================================

# Show quit confirmation dialog
func _show_quit_confirmation() -> void:
	print("MainMenu: Showing quit confirmation")

	var dialog := ConfirmationDialog.new()
	dialog.title = "Quit Game"
	dialog.dialog_text = "Are you sure you want to quit?"
	dialog.ok_button_text = "Quit"
	dialog.cancel_button_text = "Cancel"
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	add_child(dialog)

	# Connect signals
	dialog.confirmed.connect(_on_quit_confirmed)
	dialog.canceled.connect(dialog.queue_free)
	dialog.confirmed.connect(dialog.queue_free)

	dialog.popup_centered()

# Quit confirmed
func _on_quit_confirmed() -> void:
	print("MainMenu: Quitting game")

	# Fade out before quitting
	await _fade_out()

	# Quit the game
	get_tree().quit()

# =============================================================================
# FADE TRANSITIONS
# =============================================================================

# Fade in from black
func _fade_in() -> void:
	is_transitioning = true
	fade_overlay.color = FADE_COLOR
	fade_overlay.color.a = 1.0
	fade_overlay.visible = true

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_overlay, "color:a", 0.0, FADE_DURATION)

	await tween.finished
	fade_overlay.visible = false
	is_transitioning = false

# Fade out to black
func _fade_out() -> void:
	is_transitioning = true
	fade_overlay.color = FADE_COLOR
	fade_overlay.color.a = 0.0
	fade_overlay.visible = true

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fade_overlay, "color:a", 1.0, FADE_DURATION)

	await tween.finished

# =============================================================================
# BUTTON STATE MANAGEMENT
# =============================================================================

# Disable all menu buttons
func _disable_all_buttons() -> void:
	single_player_button.disabled = true
	multiplayer_button.disabled = true
	settings_button.disabled = true
	how_to_play_button.disabled = true
	credits_button.disabled = true
	quit_button.disabled = true

# Enable all menu buttons
func _enable_all_buttons() -> void:
	single_player_button.disabled = false
	multiplayer_button.disabled = false
	settings_button.disabled = false
	how_to_play_button.disabled = false
	credits_button.disabled = false
	quit_button.disabled = false

# =============================================================================
# ERROR HANDLING
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

# =============================================================================
# INPUT HANDLING
# =============================================================================

# Handle input events (for keyboard shortcuts)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# ESC key - show quit confirmation
		if active_submenu == null and not is_transitioning:
			_on_quit_pressed()
			accept_event()

# =============================================================================
# CLEANUP
# =============================================================================

# Cleanup on exit
func _exit_tree() -> void:
	print("MainMenu: Exiting")

	# Emit signal
	menu_exited.emit()

	# Clear scene references
	multiplayer_menu_scene = null
	settings_menu_scene = null
	game_scene = null
