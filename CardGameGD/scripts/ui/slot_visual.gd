class_name SlotVisual
extends Control

## Visual representation of a slot on the game board
## Replaces SlotImage.java from the original game

signal slot_clicked(slot: SlotVisual)
signal slot_hovered(slot: SlotVisual)
signal slot_unhovered(slot: SlotVisual)

# Slot state
var slot_index: int = -1
var is_occupied: bool = false
var card_visual: CardVisual = null
var owner_id: String = ""
var is_player_slot: bool = false
var is_highlighted: bool = false
var is_enemy_target: bool = false
var is_hovered: bool = false
var is_valid_drop_target: bool = false
var is_invalid_drop_target: bool = false

# Visual elements
var background: ColorRect = null
var border: ColorRect = null
var highlight: ColorRect = null
var hover_glow: ColorRect = null
var drop_indicator: ColorRect = null

# Constants
const SLOT_SIZE: Vector2 = Vector2(140, 180)
const BORDER_WIDTH: float = 3.0

# Colors
const COLOR_NORMAL: Color = Color(0.2, 0.2, 0.2, 0.5)
const COLOR_OCCUPIED: Color = Color(0.3, 0.3, 0.3, 0.7)
const COLOR_HIGHLIGHTED: Color = Color(0.5, 0.8, 0.5, 0.5)
const COLOR_ENEMY_TARGET: Color = Color(0.8, 0.2, 0.2, 0.5)
const COLOR_BORDER_NORMAL: Color = Color(0.4, 0.4, 0.4, 0.8)
const COLOR_BORDER_HIGHLIGHT: Color = Color(0.8, 0.8, 0.2, 1.0)
const COLOR_HOVER_GLOW: Color = Color(1.0, 1.0, 1.0, 0.2)
const COLOR_VALID_DROP: Color = Color(0.3, 1.0, 0.3, 0.6)
const COLOR_INVALID_DROP: Color = Color(1.0, 0.3, 0.3, 0.6)

func _ready() -> void:
	custom_minimum_size = SLOT_SIZE
	size = SLOT_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	_create_visual_elements()

func _create_visual_elements() -> void:
	# Border
	border = ColorRect.new()
	border.color = COLOR_BORDER_NORMAL
	border.position = Vector2.ZERO
	border.size = SLOT_SIZE
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(border)

	# Background
	background = ColorRect.new()
	background.color = COLOR_NORMAL
	background.position = Vector2(BORDER_WIDTH, BORDER_WIDTH)
	background.size = SLOT_SIZE - Vector2(BORDER_WIDTH * 2, BORDER_WIDTH * 2)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	# Highlight overlay (initially hidden)
	highlight = ColorRect.new()
	highlight.color = COLOR_HIGHLIGHTED
	highlight.position = Vector2(BORDER_WIDTH, BORDER_WIDTH)
	highlight.size = SLOT_SIZE - Vector2(BORDER_WIDTH * 2, BORDER_WIDTH * 2)
	highlight.visible = false
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(highlight)

	# Hover glow (initially hidden)
	hover_glow = ColorRect.new()
	hover_glow.color = COLOR_HOVER_GLOW
	hover_glow.position = Vector2(BORDER_WIDTH, BORDER_WIDTH)
	hover_glow.size = SLOT_SIZE - Vector2(BORDER_WIDTH * 2, BORDER_WIDTH * 2)
	hover_glow.visible = false
	hover_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hover_glow)

	# Drop indicator (initially hidden)
	drop_indicator = ColorRect.new()
	drop_indicator.color = COLOR_VALID_DROP
	drop_indicator.position = Vector2(BORDER_WIDTH, BORDER_WIDTH)
	drop_indicator.size = SLOT_SIZE - Vector2(BORDER_WIDTH * 2, BORDER_WIDTH * 2)
	drop_indicator.visible = false
	drop_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(drop_indicator)

func setup_slot(index: int, owner: String, is_player: bool) -> void:
	slot_index = index
	owner_id = owner
	is_player_slot = is_player
	_update_visual()

func set_occupied(occupied: bool) -> void:
	is_occupied = occupied
	_update_visual()

func get_occupied() -> bool:
	return is_occupied

func set_card(card_vis: CardVisual) -> void:
	# Remove existing card if any
	if card_visual != null and card_visual.get_parent() == self:
		remove_child(card_visual)

	card_visual = card_vis
	is_occupied = (card_vis != null)

	if card_visual != null:
		# Add card to slot
		add_child(card_visual)
		# Center the card in the slot
		var card_size: Vector2 = card_visual.size
		var offset_x: float = (SLOT_SIZE.x - card_size.x) / 2.0
		var offset_y: float = (SLOT_SIZE.y - card_size.y) / 2.0
		card_visual.position = Vector2(offset_x, offset_y)

	_update_visual()

func get_card() -> CardVisual:
	return card_visual

func remove_card() -> CardVisual:
	var removed_card: CardVisual = card_visual

	if card_visual != null and card_visual.get_parent() == self:
		remove_child(card_visual)

	card_visual = null
	is_occupied = false
	_update_visual()

	return removed_card

func set_highlighted(highlighted: bool, as_enemy_target: bool = false) -> void:
	is_highlighted = highlighted
	is_enemy_target = as_enemy_target
	_update_visual()

func get_slot_index() -> int:
	return slot_index

func is_empty() -> bool:
	return not is_occupied

func get_owner_id() -> String:
	return owner_id

func is_player_owned() -> bool:
	return is_player_slot

func _update_visual() -> void:
	if background == null:
		return

	# Update background color based on state
	if is_occupied:
		background.color = COLOR_OCCUPIED
	else:
		background.color = COLOR_NORMAL

	# Update highlight
	if is_highlighted:
		highlight.visible = true
		if is_enemy_target:
			highlight.color = COLOR_ENEMY_TARGET
		else:
			highlight.color = COLOR_HIGHLIGHTED
	else:
		highlight.visible = false

	# Update hover glow
	if hover_glow:
		hover_glow.visible = is_hovered and not is_valid_drop_target and not is_invalid_drop_target

	# Update drop indicator
	if drop_indicator:
		if is_valid_drop_target:
			drop_indicator.visible = true
			drop_indicator.color = COLOR_VALID_DROP
		elif is_invalid_drop_target:
			drop_indicator.visible = true
			drop_indicator.color = COLOR_INVALID_DROP
		else:
			drop_indicator.visible = false

	# Update border color
	if is_highlighted or is_valid_drop_target:
		border.color = COLOR_BORDER_HIGHLIGHT
	elif is_invalid_drop_target:
		border.color = Color(1.0, 0.3, 0.3, 1.0)
	else:
		border.color = COLOR_BORDER_NORMAL

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			slot_clicked.emit(self)
			accept_event()

func _on_mouse_entered() -> void:
	is_hovered = true
	_update_visual()
	slot_hovered.emit(self)

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_visual()
	slot_unhovered.emit(self)

func set_drop_target(valid: bool) -> void:
	"""Set this slot as a valid or invalid drop target."""
	is_valid_drop_target = valid
	is_invalid_drop_target = not valid if (is_valid_drop_target or is_invalid_drop_target) else false
	_update_visual()

	# Add pulsating animation for drop targets
	if is_valid_drop_target or is_invalid_drop_target:
		_start_drop_indicator_pulse()

func clear_drop_target() -> void:
	"""Clear drop target status."""
	is_valid_drop_target = false
	is_invalid_drop_target = false
	_update_visual()

func _start_drop_indicator_pulse() -> void:
	"""Animate the drop indicator with pulsating effect."""
	if not drop_indicator:
		return

	var tween := create_tween()
	tween.set_loops()
	var target_color := COLOR_VALID_DROP if is_valid_drop_target else COLOR_INVALID_DROP
	var pulse_color := Color(target_color.r, target_color.g, target_color.b, 0.3)
	tween.tween_property(drop_indicator, "color", target_color, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(drop_indicator, "color", pulse_color, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func play_occupation_animation() -> void:
	"""Play animation when a card is placed in this slot."""
	if not card_visual:
		return

	# Start from smaller scale and fade in
	card_visual.scale = Vector2(0.5, 0.5)
	card_visual.modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(card_visual, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_visual, "modulate:a", 1.0, 0.2)

	# Play sound if available
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.SUMMON_DROP)

func get_creature() -> BaseCreature:
	"""Get the creature instance from the card in this slot."""
	if card_visual != null:
		return card_visual.get_creature()
	return null

func update_creature_visual() -> void:
	"""Force the card visual to update if it contains a creature."""
	if card_visual != null and card_visual.creature != null:
		card_visual.update_visual()

func _to_string() -> String:
	var status: String = "occupied" if is_occupied else "empty"
	var owner_str: String = "player" if is_player_slot else "opponent"
	return "SlotVisual[%d](%s, %s)" % [slot_index, owner_str, status]
