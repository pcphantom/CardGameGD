class_name PlayerImage
extends Control

## Visual representation of a player's interface
## Replaces PlayerImage.java from the original game

signal hand_card_clicked(card: CardImage)
signal hand_card_hovered(card: CardImage)
signal slot_clicked(slot: SlotImage)
signal slot_hovered(slot: SlotImage)

# Player data
var player_info: Player = null
var is_local_player: bool = false
var hand_cards: Array[CardImage] = []
var slot_visuals: Array[SlotImage] = []

# UI elements
var panel: Panel = null
var portrait: TextureRect = null
var name_label: Label = null
var life_label: Label = null
var life_bar: ProgressBar = null
var strength_labels: Dictionary = {}
var turn_indicator: ColorRect = null
var turn_glow_tween: Tween = null

# Layout constants
const PORTRAIT_SIZE: Vector2 = Vector2(50, 50)
const HAND_CARD_SPACING: float = 130.0
const HAND_Y_LOCAL: float = 600.0
const HAND_Y_OPPONENT: float = 80.0
const SLOTS_Y_LOCAL: float = 420.0
const SLOTS_Y_OPPONENT: float = 110.0
const PANEL_Y_LOCAL: float = 700.0
const PANEL_Y_OPPONENT: float = 0.0
const PANEL_HEIGHT: float = 68.0

func _ready() -> void:
	_create_ui_elements()

func _create_ui_elements() -> void:
	# Panel
	panel = Panel.new()
	panel.custom_minimum_size = Vector2(1024, PANEL_HEIGHT)
	add_child(panel)

	# Turn indicator (glowing border)
	turn_indicator = ColorRect.new()
	turn_indicator.color = Color(1.0, 0.84, 0.0, 0.0)  # Gold, initially transparent
	turn_indicator.position = Vector2(-2, -2)
	turn_indicator.size = Vector2(1028, PANEL_HEIGHT + 4)
	turn_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	turn_indicator.z_index = -1
	panel.add_child(turn_indicator)

	# Portrait
	portrait = TextureRect.new()
	portrait.custom_minimum_size = PORTRAIT_SIZE
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.add_child(portrait)

	# Portrait placeholder background (avatar icon)
	var portrait_bg := ColorRect.new()
	portrait_bg.color = Color(0.2, 0.3, 0.5)
	portrait_bg.custom_minimum_size = PORTRAIT_SIZE
	portrait_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(portrait_bg)
	panel.move_child(portrait_bg, 0)

	# Avatar icon (simple player icon using a Label)
	var avatar_icon := Label.new()
	avatar_icon.text = "👤"
	avatar_icon.add_theme_font_size_override("font_size", 32)
	avatar_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar_icon.position = Vector2(10, 9)
	avatar_icon.size = PORTRAIT_SIZE
	avatar_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(avatar_icon)

	# Name label
	name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(name_label)

	# Life label
	life_label = Label.new()
	life_label.add_theme_font_size_override("font_size", 32)
	life_label.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(life_label)

	# Life bar
	life_bar = ProgressBar.new()
	life_bar.min_value = 0
	life_bar.max_value = 50
	life_bar.value = 50
	life_bar.show_percentage = false
	life_bar.custom_minimum_size = Vector2(140, 10)
	# Style the life bar
	var life_bar_style := StyleBoxFlat.new()
	life_bar_style.bg_color = Color(1, 0.3, 0.3, 0.8)
	life_bar.add_theme_stylebox_override("fill", life_bar_style)
	panel.add_child(life_bar)

	# Strength labels for each resource type
	var resource_types: Array = [
		CardType.Type.FIRE,
		CardType.Type.WATER,
		CardType.Type.AIR,
		CardType.Type.EARTH,
		CardType.Type.OTHER
	]

	for i in range(resource_types.size()):
		var res_type = resource_types[i]
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 24)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		# Color code by type
		match res_type:
			CardType.Type.FIRE:
				label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
			CardType.Type.WATER:
				label.add_theme_color_override("font_color", Color(0.3, 0.5, 1))
			CardType.Type.AIR:
				label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.5))
			CardType.Type.EARTH:
				label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.2))
			CardType.Type.OTHER:
				label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

		panel.add_child(label)
		strength_labels[res_type] = label

func setup_player(player: Player, is_local: bool) -> void:
	player_info = player
	is_local_player = is_local

	# Position panel - EXACT coordinates
	panel.position = Vector2(0, PANEL_Y_LOCAL if is_local else PANEL_Y_OPPONENT)
	panel.custom_minimum_size = Vector2(1024, PANEL_HEIGHT)

	# Position portrait - EXACT coordinates
	portrait.position = Vector2(10, 9)
	portrait.size = PORTRAIT_SIZE

	# Position name label - EXACT coordinates
	name_label.position = Vector2(70, 5)
	name_label.size = Vector2(150, 20)

	# Position life label - EXACT coordinates
	life_label.position = Vector2(70, 25)
	life_label.size = Vector2(150, 25)
	life_label.add_theme_font_size_override("font_size", 32)

	# Position life bar - EXACT coordinates
	life_bar.position = Vector2(70, 50)
	life_bar.size = Vector2(90, 10)

	# Position strength labels - EXACT coordinates
	var resource_types: Array = [
		CardType.Type.FIRE,
		CardType.Type.WATER,
		CardType.Type.AIR,
		CardType.Type.EARTH,
		CardType.Type.OTHER
	]

	for i in range(resource_types.size()):
		var res_type = resource_types[i]
		if strength_labels.has(res_type):
			var label: Label = strength_labels[res_type]
			label.position = Vector2(160 + i * 100, 15)  # Exact spacing: 160, 260, 360, 460, 560
			label.size = Vector2(90, 30)
			label.add_theme_font_size_override("font_size", 24)

			# Set exact colors for each element
			match res_type:
				CardType.Type.FIRE:
					label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
				CardType.Type.WATER:
					label.add_theme_color_override("font_color", Color(0.3, 0.5, 1.0))
				CardType.Type.AIR:
					label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.5))
				CardType.Type.EARTH:
					label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.2))
				CardType.Type.OTHER:
					label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

	# Setup board slots
	setup_slots(player.get_id())

	# Update display
	update_display()

func setup_slots(owner_id: String) -> void:
	# Clear existing slots
	for slot in slot_visuals:
		if slot.get_parent() == self:
			remove_child(slot)
	slot_visuals.clear()

	# Create 6 slots
	var slots_y: float = SLOTS_Y_LOCAL if is_local_player else SLOTS_Y_OPPONENT
	var slot_x_positions: Array[float] = [80.0, 240.0, 400.0, 560.0, 720.0, 880.0]

	for i in range(6):
		var slot := SlotImage.new()
		slot.setup_slot(i, owner_id, is_local_player)
		slot.position = Vector2(slot_x_positions[i], slots_y)
		add_child(slot)
		slot_visuals.append(slot)

		# Connect signals
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.slot_hovered.connect(_on_slot_hovered)

func update_display() -> void:
	if player_info == null:
		return

	# Update name
	name_label.text = player_info.get_name()

	# Update life and resources
	update_life_display()
	update_strength_displays()

	# Update hand layout
	_update_hand_layout()

func update_life_display() -> void:
	if player_info == null:
		return

	var current_life := player_info.get_life()
	life_label.text = "HP: %d" % current_life

	# Animate life bar with smooth transition
	if life_bar:
		var tween := create_tween()
		tween.tween_property(life_bar, "value", float(current_life), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		# Change life bar color based on health percentage
		var health_percent := float(current_life) / life_bar.max_value
		var bar_color: Color
		if health_percent > 0.6:
			bar_color = Color(0.3, 1.0, 0.3, 0.8)  # Green
		elif health_percent > 0.3:
			bar_color = Color(1.0, 0.84, 0.0, 0.8)  # Yellow
		else:
			bar_color = Color(1.0, 0.3, 0.3, 0.8)  # Red

		var life_bar_style := StyleBoxFlat.new()
		life_bar_style.bg_color = bar_color
		life_bar.add_theme_stylebox_override("fill", life_bar_style)

func update_strength_displays() -> void:
	if player_info == null:
		return

	var strength := player_info.strength

	var resource_types: Array = [
		CardType.Type.FIRE,
		CardType.Type.WATER,
		CardType.Type.AIR,
		CardType.Type.EARTH,
		CardType.Type.OTHER
	]

	for res_type in resource_types:
		if strength_labels.has(res_type):
			var label: Label = strength_labels[res_type]
			var value: int = strength.get(res_type, 0)
			var type_name: String = _get_type_name(res_type)
			label.text = "%s: %d" % [type_name, value]

func _get_type_name(card_type: int) -> String:
	match card_type:
		CardType.Type.FIRE:
			return "Fire"
		CardType.Type.WATER:
			return "Water"
		CardType.Type.AIR:
			return "Air"
		CardType.Type.EARTH:
			return "Earth"
		CardType.Type.OTHER:
			return "Other"
		_:
			return "Unknown"

func add_card_to_hand(card: Card) -> void:
	var card_visual := CardImage.new()
	card_visual.setup_card(card, "small")
	add_child(card_visual)
	hand_cards.append(card_visual)

	# Connect signals
	card_visual.card_clicked.connect(_on_hand_card_clicked)
	card_visual.card_hovered.connect(_on_hand_card_hovered)

	_update_hand_layout()

func remove_card_from_hand(card_visual: CardImage) -> void:
	var index := hand_cards.find(card_visual)
	if index >= 0:
		hand_cards.remove_at(index)
		if card_visual.get_parent() == self:
			remove_child(card_visual)
		_update_hand_layout()

func _update_hand_layout() -> void:
	var hand_y: float = HAND_Y_LOCAL if is_local_player else HAND_Y_OPPONENT
	var num_cards: int = hand_cards.size()

	if num_cards == 0:
		return

	# Center the hand
	var total_width: float = num_cards * HAND_CARD_SPACING
	var start_x: float = (1024 - total_width) / 2.0

	for i in range(num_cards):
		var card_visual: CardImage = hand_cards[i]
		card_visual.position = Vector2(start_x + i * HAND_CARD_SPACING, hand_y)

func get_hand_cards() -> Array:
	return hand_cards.duplicate()

func get_slot_cards() -> Array:
	var cards: Array = []
	for slot in slot_visuals:
		var card := slot.get_card()
		if card != null:
			cards.append(card)
	return cards

func get_slots() -> Array:
	return slot_visuals.duplicate()

func get_slot_at_index(index: int) -> SlotImage:
	if index >= 0 and index < slot_visuals.size():
		return slot_visuals[index]
	return null

func get_player_info() -> Player:
	return player_info

func set_player_info(player: Player) -> void:
	player_info = player
	update_display()

func find_card_visual_by_card(card: Card) -> CardImage:
	"""Find a CardImage in hand by its Card data."""
	for card_visual in hand_cards:
		if card_visual.get_card() == card:
			return card_visual
	return null

func highlight_slot(index: int, highlighted: bool, as_enemy_target: bool = false) -> void:
	"""Highlight a specific slot for targeting."""
	var slot := get_slot_at_index(index)
	if slot != null:
		slot.set_highlighted(highlighted, as_enemy_target)

func highlight_all_slots(highlighted: bool, as_enemy_target: bool = false) -> void:
	"""Highlight all slots."""
	for slot in slot_visuals:
		slot.set_highlighted(highlighted, as_enemy_target)

func get_empty_slot_indices() -> Array[int]:
	"""Get indices of all empty slots."""
	var indices: Array[int] = []
	for slot in slot_visuals:
		if slot.is_empty():
			indices.append(slot.get_slot_index())
	return indices

func get_occupied_slot_indices() -> Array[int]:
	"""Get indices of all occupied slots."""
	var indices: Array[int] = []
	for slot in slot_visuals:
		if not slot.is_empty():
			indices.append(slot.get_slot_index())
	return indices

func _on_hand_card_clicked(card_visual: CardImage) -> void:
	hand_card_clicked.emit(card_visual)

func _on_hand_card_hovered(card_visual: CardImage) -> void:
	hand_card_hovered.emit(card_visual)

func _on_slot_clicked(slot: SlotImage) -> void:
	slot_clicked.emit(slot)

func _on_slot_hovered(slot: SlotImage) -> void:
	slot_hovered.emit(slot)

func set_turn_active(active: bool) -> void:
	"""Show/hide turn indicator with pulsating glow effect."""
	if not turn_indicator:
		return

	# Stop existing tween
	if turn_glow_tween and turn_glow_tween.is_valid():
		turn_glow_tween.kill()

	if active:
		# Start pulsating glow
		turn_glow_tween = create_tween()
		turn_glow_tween.set_loops()
		turn_glow_tween.tween_property(turn_indicator, "color:a", 0.7, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		turn_glow_tween.tween_property(turn_indicator, "color:a", 0.3, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		# Fade out glow
		turn_glow_tween = create_tween()
		turn_glow_tween.tween_property(turn_indicator, "color:a", 0.0, 0.3)

func add_elemental_power_animation(element_type: int, amount: int) -> void:
	"""Animate elemental power changes."""
	if not strength_labels.has(element_type):
		return

	var label: Label = strength_labels[element_type]

	# Create floating text to show change
	var change_label := Label.new()
	change_label.text = "+%d" % amount if amount > 0 else "%d" % amount
	change_label.add_theme_font_size_override("font_size", 18)
	change_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3) if amount > 0 else Color(1.0, 0.3, 0.3))
	change_label.position = label.position + Vector2(0, -20)
	change_label.modulate.a = 0.0
	panel.add_child(change_label)

	# Animate floating and fading
	var tween := create_tween()
	tween.tween_property(change_label, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(change_label, "position:y", change_label.position.y - 30, 1.0)
	tween.tween_property(change_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(change_label.queue_free)

	# Pulse the label
	var pulse_tween := create_tween()
	pulse_tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15)
	pulse_tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15)

func _to_string() -> String:
	var player_name: String = player_info.get_name() if player_info != null else "Unknown"
	var side: String = "local" if is_local_player else "opponent"
	return "PlayerImage(%s, %s)" % [player_name, side]
