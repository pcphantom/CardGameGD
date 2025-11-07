class_name LogPanel
extends Panel

## Game log display panel
## Replaces LogScrollPane.java from the original game

# Configuration
var max_entries: int = 50
var auto_scroll: bool = true
var active_filters: Dictionary = {
	"summon": true,
	"attack": true,
	"death": true,
	"spell": true,
	"damage": true,
	"heal": true,
	"buff": true,
	"normal": true,
	"game_over": true
}

# Log entries
var log_entries: Array[Dictionary] = []  # {label: Label, type: String}

# UI elements
var title_label: Label = null
var scroll_container: ScrollContainer = null
var entries_container: VBoxContainer = null
var filter_button: Button = null
var filter_panel: Panel = null
var auto_scroll_checkbox: CheckBox = null

# Color constants for event types
const COLOR_NORMAL: Color = Color.WHITE
const COLOR_SUMMON: Color = Color(0.4, 1.0, 0.4)  # Green
const COLOR_ATTACK: Color = Color(1.0, 0.3, 0.3)  # Red
const COLOR_DEATH: Color = Color(0.6, 0.6, 0.6)  # Gray
const COLOR_SPELL: Color = Color(0.4, 0.8, 1.0)  # Cyan
const COLOR_GAME_OVER: Color = Color(1.0, 1.0, 0.4)  # Yellow
const COLOR_DAMAGE: Color = Color(1.0, 0.5, 0.2)  # Orange
const COLOR_HEAL: Color = Color(0.5, 1.0, 0.7)  # Light green
const COLOR_BUFF: Color = Color(0.8, 0.6, 1.0)  # Purple

# Size constants
const PANEL_SIZE: Vector2 = Vector2(160, 580)
const PANEL_POSITION: Vector2 = Vector2(850, 100)

func _ready() -> void:
	custom_minimum_size = PANEL_SIZE
	size = PANEL_SIZE
	position = PANEL_POSITION

	_create_ui_elements()

	# Connect to GameManager signals if available
	if GameManager:
		GameManager.game_log_added.connect(_on_game_log_added)

func _create_ui_elements() -> void:
	# Title label
	title_label = Label.new()
	title_label.text = "Game Log"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.position = Vector2(5, 5)
	title_label.size = Vector2(100, 25)
	add_child(title_label)

	# Filter button
	filter_button = Button.new()
	filter_button.text = "⚙"
	filter_button.tooltip_text = "Filter options"
	filter_button.position = Vector2(110, 5)
	filter_button.size = Vector2(25, 25)
	filter_button.pressed.connect(_on_filter_button_pressed)
	add_child(filter_button)

	# Auto-scroll checkbox
	auto_scroll_checkbox = CheckBox.new()
	auto_scroll_checkbox.text = ""
	auto_scroll_checkbox.tooltip_text = "Auto-scroll"
	auto_scroll_checkbox.button_pressed = true
	auto_scroll_checkbox.position = Vector2(137, 5)
	auto_scroll_checkbox.size = Vector2(20, 25)
	auto_scroll_checkbox.toggled.connect(_on_auto_scroll_toggled)
	add_child(auto_scroll_checkbox)

	# Scroll container
	scroll_container = ScrollContainer.new()
	scroll_container.position = Vector2(5, 35)
	scroll_container.size = Vector2(150, 540)
	scroll_container.follow_focus = true
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(scroll_container)

	# Entries container
	entries_container = VBoxContainer.new()
	entries_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(entries_container)

	# Filter panel (initially hidden)
	_create_filter_panel()

func add(message: String) -> void:
	"""Add a normal log entry."""
	_add_with_type(message, COLOR_NORMAL, "normal")

func add_with_color(message: String, color: Color) -> void:
	"""Add a log entry with custom color."""
	_add_with_type(message, color, "normal")

func _add_with_type(message: String, color: Color, event_type: String) -> void:
	"""Add a log entry with custom color and type."""
	var timestamp := _get_timestamp()
	var formatted_text := "[%s] %s" % [timestamp, message]

	var entry_label := Label.new()
	entry_label.text = formatted_text
	entry_label.add_theme_color_override("font_color", color)
	entry_label.add_theme_font_size_override("font_size", 10)
	entry_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry_label.custom_minimum_size = Vector2(140, 0)

	# Check if this type is filtered
	if active_filters.get(event_type, true):
		entry_label.visible = true
	else:
		entry_label.visible = false

	entries_container.add_child(entry_label)
	log_entries.append({"label": entry_label, "type": event_type})

	# Enforce max entries limit
	if log_entries.size() > max_entries:
		var removed_entry := log_entries[0]
		log_entries.remove_at(0)
		removed_entry["label"].queue_free()

	# Auto-scroll to bottom
	if auto_scroll:
		scroll_to_bottom()

func add_summon(creature_name: String, player_name: String, slot: int) -> void:
	"""Add a summon log entry."""
	var message := "%s summoned %s to slot %d" % [player_name, creature_name, slot]
	_add_with_type(message, COLOR_SUMMON, "summon")

func add_attack(attacker: String, defender: String, damage: int) -> void:
	"""Add an attack log entry."""
	var message := "%s attacks %s for %d damage" % [attacker, defender, damage]
	_add_with_type(message, COLOR_ATTACK, "attack")

func add_death(creature_name: String) -> void:
	"""Add a death log entry."""
	var message := "%s died" % creature_name
	_add_with_type(message, COLOR_DEATH, "death")

func add_spell(spell_name: String, caster_name: String) -> void:
	"""Add a spell cast log entry."""
	var message := "%s cast %s" % [caster_name, spell_name]
	_add_with_type(message, COLOR_SPELL, "spell")

func add_game_over(winner_name: String) -> void:
	"""Add a game over log entry."""
	var message := "GAME OVER - %s wins!" % winner_name
	_add_with_type(message, COLOR_GAME_OVER, "game_over")

func add_damage(target: String, damage: int) -> void:
	"""Add a damage log entry."""
	var message := "%s takes %d damage" % [target, damage]
	_add_with_type(message, COLOR_DAMAGE, "damage")

func add_heal(target: String, amount: int) -> void:
	"""Add a heal log entry."""
	var message := "%s heals %d life" % [target, amount]
	_add_with_type(message, COLOR_HEAL, "heal")

func add_buff(target: String, buff_description: String) -> void:
	"""Add a buff/debuff log entry."""
	var message := "%s: %s" % [target, buff_description]
	_add_with_type(message, COLOR_BUFF, "buff")

func clear() -> void:
	"""Clear all log entries."""
	for entry in log_entries:
		entry["label"].queue_free()
	log_entries.clear()

func scroll_to_bottom() -> void:
	"""Scroll to the bottom of the log."""
	# Need to wait for next frame for layout to update
	await get_tree().process_frame
	if scroll_container:
		scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func set_auto_scroll(enabled: bool) -> void:
	"""Enable or disable auto-scrolling."""
	auto_scroll = enabled

func get_entry_count() -> int:
	"""Get the number of log entries."""
	return log_entries.size()

func _get_timestamp() -> String:
	"""Generate a timestamp string."""
	var time := Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [time.hour, time.minute, time.second]

func _on_game_log_added(message: String, event_type: String = "normal") -> void:
	"""Handle log messages from GameManager."""
	var color: Color = COLOR_NORMAL

	match event_type:
		"summon":
			color = COLOR_SUMMON
		"attack":
			color = COLOR_ATTACK
		"death":
			color = COLOR_DEATH
		"spell":
			color = COLOR_SPELL
		"game_over":
			color = COLOR_GAME_OVER
		"damage":
			color = COLOR_DAMAGE
		"heal":
			color = COLOR_HEAL
		"buff":
			color = COLOR_BUFF
		_:
			color = COLOR_NORMAL

	_add_with_type(message, color, event_type)

func get_log_text() -> String:
	"""Get all log entries as a single string."""
	var lines: Array[String] = []
	for entry in log_entries:
		lines.append(entry["label"].text)
	return "\n".join(lines)

func save_log_to_file(file_path: String) -> bool:
	"""Save the log to a text file."""
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(get_log_text())
		file.close()
		return true
	return false

func _create_filter_panel() -> void:
	"""Create the filter panel with checkboxes for each event type."""
	filter_panel = Panel.new()
	filter_panel.custom_minimum_size = Vector2(140, 250)
	filter_panel.position = Vector2(165, 35)
	filter_panel.visible = false
	filter_panel.z_index = 100
	add_child(filter_panel)

	var vbox := VBoxContainer.new()
	vbox.position = Vector2(5, 5)
	vbox.size = Vector2(130, 240)
	filter_panel.add_child(vbox)

	var title := Label.new()
	title.text = "Filter Messages"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 12)
	vbox.add_child(title)

	# Create checkbox for each filter type
	var filter_types := ["summon", "attack", "death", "spell", "damage", "heal", "buff", "normal", "game_over"]
	var filter_labels := {
		"summon": "Summons",
		"attack": "Attacks",
		"death": "Deaths",
		"spell": "Spells",
		"damage": "Damage",
		"heal": "Healing",
		"buff": "Buffs",
		"normal": "Normal",
		"game_over": "Game Over"
	}

	for filter_type in filter_types:
		var checkbox := CheckBox.new()
		checkbox.text = filter_labels.get(filter_type, filter_type)
		checkbox.button_pressed = active_filters.get(filter_type, true)
		checkbox.toggled.connect(_on_filter_toggled.bind(filter_type))
		vbox.add_child(checkbox)

func _on_filter_button_pressed() -> void:
	"""Toggle filter panel visibility."""
	filter_panel.visible = not filter_panel.visible

func _on_auto_scroll_toggled(enabled: bool) -> void:
	"""Toggle auto-scroll."""
	auto_scroll = enabled

func _on_filter_toggled(enabled: bool, filter_type: String) -> void:
	"""Toggle a specific filter."""
	active_filters[filter_type] = enabled

	# Update visibility of existing entries
	for entry in log_entries:
		if entry["type"] == filter_type:
			entry["label"].visible = enabled

func _to_string() -> String:
	return "LogPanel(%d entries)" % log_entries.size()
