class_name GameController
extends Node2D

## Main game controller
## Replaces Cards.java main game logic from the original game

# Player visuals
var player_visual: PlayerVisual = null
var opponent_visual: PlayerVisual = null

# Game state
var local_player: Player = null
var opponent_player: Player = null

# Player decks and hands
var player_deck: Array = []
var player_hand: Array = []
var opponent_deck: Array = []
var opponent_hand: Array = []
var selected_card: CardVisual = null
var selected_slot: SlotVisual = null
var is_turn_active: bool = false
var current_turn_player_id: String = ""

# Multiplayer state
var is_multiplayer: bool = false
var is_my_turn: bool = true

# UI elements
var end_turn_button: Button = null
var log_panel: LogPanel = null
var victory_defeat_screen: Panel = null
var pause_menu: Panel = null
var turn_timer_label: Label = null
var fps_counter_label: Label = null
var tooltip_panel: Panel = null

# UI state
var is_paused: bool = false
var show_fps: bool = false
var turn_time_elapsed: float = 0.0

# Awaiting target selection
var awaiting_target: bool = false
var awaiting_summon_slot: bool = false

func _ready() -> void:
	# Start background music
	if SoundManager:
		SoundManager.start_background_music()
		print("GameController: Background music started")

	initialize_game()
	_create_victory_defeat_screen()
	_create_pause_menu()
	_create_turn_timer()
	_create_fps_counter()
	_create_tooltip_panel()

func _process(delta: float) -> void:
	# Update turn timer
	if is_turn_active and is_my_turn:
		turn_time_elapsed += delta
		if turn_timer_label:
			var minutes := int(turn_time_elapsed) / 60
			var seconds := int(turn_time_elapsed) % 60
			turn_timer_label.text = "Turn: %d:%02d" % [minutes, seconds]

	# Update FPS counter
	if show_fps and fps_counter_label:
		fps_counter_label.text = "FPS: %d" % Engine.get_frames_per_second()
		fps_counter_label.visible = true
	elif fps_counter_label:
		fps_counter_label.visible = false

func _input(event: InputEvent) -> void:
	# Pause menu toggle
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause_menu()
		get_viewport().set_input_as_handled()

	# FPS counter toggle (F3 key)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		show_fps = not show_fps
		get_viewport().set_input_as_handled()

func initialize_game() -> void:
	# Check if this is a multiplayer game
	is_multiplayer = NetworkManager.is_multiplayer_game
	is_my_turn = NetworkManager.is_my_turn if is_multiplayer else true

	# Get UI elements from scene
	_setup_ui_references()

	# Create players
	create_players()

	# Setup player visuals
	_setup_player_visuals()

	# Connect signals
	connect_signals()

	# Setup starting decks and draw initial hands
	setup_starting_decks()

	# Start first turn
	start_first_turn()

	if is_multiplayer:
		log_panel.add_with_color("Multiplayer game started!", LogPanel.COLOR_GAME_OVER)
	else:
		log_panel.add_with_color("Game started!", LogPanel.COLOR_GAME_OVER)

func _setup_ui_references() -> void:
	# Create player visuals
	player_visual = PlayerVisual.new()
	player_visual.name = "PlayerVisual"
	add_child(player_visual)

	opponent_visual = PlayerVisual.new()
	opponent_visual.name = "OpponentVisual"
	add_child(opponent_visual)

	# Get end turn button from scene
	end_turn_button = get_node_or_null("GameUI/EndTurnButton")
	if end_turn_button:
		end_turn_button.pressed.connect(on_end_turn_pressed)

	# Create log panel
	log_panel = LogPanel.new()
	log_panel.name = "LogPanel"
	add_child(log_panel)

func create_players() -> void:
	# Create local player
	local_player = Player.new()
	local_player.set_name("Player")
	local_player.set_life(50)

	# Set starting resources
	local_player.strength[CardType.Type.FIRE] = 1
	local_player.strength[CardType.Type.WATER] = 1
	local_player.strength[CardType.Type.AIR] = 1
	local_player.strength[CardType.Type.EARTH] = 1
	local_player.strength[CardType.Type.OTHER] = 1

	# Create opponent
	opponent_player = Player.new()
	opponent_player.set_name("Opponent")
	opponent_player.set_life(50)

	# Set starting resources
	opponent_player.strength[CardType.Type.FIRE] = 1
	opponent_player.strength[CardType.Type.WATER] = 1
	opponent_player.strength[CardType.Type.AIR] = 1
	opponent_player.strength[CardType.Type.EARTH] = 1
	opponent_player.strength[CardType.Type.OTHER] = 1

func _setup_player_visuals() -> void:
	# Setup local player visual
	player_visual.setup_player(local_player, true)

	# Setup opponent visual
	opponent_visual.setup_player(opponent_player, false)

func setup_starting_decks() -> void:
	# Add test cards to player deck
	_add_test_cards_to_player(local_player)
	_add_test_cards_to_player(opponent_player)

	# Draw initial hands
	for i in range(5):
		_draw_card(local_player, player_visual)
		_draw_card(opponent_player, opponent_visual)

func _add_test_cards_to_player(player: Player) -> void:
	# REASON FOR EDIT: Fix deck selection - was always adding to player_deck
	# PROBLEM: Method is called for both local_player AND opponent_player
	# PROBLEM: But it always added cards to player_deck
	# FIX: Check which player this is and add to the correct deck array
	# WHY: Opponent needs cards in opponent_deck, not player_deck

	var deck: Array

	# Determine which deck to use based on player ID
	if player.get_id() == local_player.get_id():
		deck = player_deck
	else:
		deck = opponent_deck

	# Create test creature cards
	for i in range(10):
		var card := Card.new()
		card.set_name("Test Creature %d" % (i + 1))
		card.set_spell(false)
		card.set_attack(3 + i % 3)
		card.set_life(5 + i % 5)
		card.set_type(CardType.Type.FIRE + (i % 5))
		card.set_cost(2 + i % 3)
		deck.append(card)

	# Create test spell cards
	for i in range(5):
		var card := Card.new()
		card.set_name("Test Spell %d" % (i + 1))
		card.set_spell(true)
		card.set_type(CardType.Type.FIRE + (i % 5))
		card.set_cost(3)
		deck.append(card)

func _draw_card(player: Player, visual: PlayerVisual) -> void:
	# REASON FOR EDIT: Fix deck/hand selection - was always using player_deck/player_hand
	# PROBLEM: Method was called for both local_player AND opponent_player
	# PROBLEM: But it always drew from player_deck and added to player_hand
	# FIX: Check which player this is and use the correct deck/hand arrays
	# WHY: Opponent needs to draw from opponent_deck, not player_deck

	var deck: Array
	var hand: Array

	# Determine which deck and hand to use based on player ID
	if player.get_id() == local_player.get_id():
		deck = player_deck
		hand = player_hand
	else:
		deck = opponent_deck
		hand = opponent_hand

	if deck.size() > 0:
		var card: Card = deck.pop_front()
		hand.append(card)
		visual.add_card_to_hand(card)

func start_first_turn() -> void:
	current_turn_player_id = local_player.get_id()
	is_turn_active = true

	GameManager.start_turn(local_player.get_id())
	log_panel.add_with_color("Your turn!", LogPanel.COLOR_NORMAL)

	# Add resources at start of turn
	_add_turn_resources(local_player)
	player_visual.update_display()

func connect_signals() -> void:
	# Connect GameManager signals
	if GameManager:
		GameManager.game_over.connect(_on_game_over)
		GameManager.turn_started.connect(_on_turn_started)
		GameManager.card_summoned.connect(_on_card_summoned)

	# Connect NetworkManager signals (if multiplayer)
	if NetworkManager and is_multiplayer:
		NetworkManager.network_event_received.connect(_on_network_event_received)
		NetworkManager.turn_started.connect(_on_multiplayer_turn_started)
		NetworkManager.turn_ended.connect(_on_multiplayer_turn_ended)
		print("GameController: Connected to NetworkManager signals")

	# Connect player visual signals
	if player_visual:
		player_visual.hand_card_clicked.connect(_on_player_hand_card_clicked)
		player_visual.slot_clicked.connect(_on_player_slot_clicked)

	if opponent_visual:
		opponent_visual.slot_clicked.connect(_on_opponent_slot_clicked)

func on_end_turn_pressed() -> void:
	if not is_turn_active:
		return

	# Check if it's player's turn in multiplayer
	if is_multiplayer and not is_my_turn:
		log_panel.add_with_color("Wait for your turn!", LogPanel.COLOR_DAMAGE)
		return

	# Clear selection
	_clear_selection()

	# Send end turn check events for all player cards
	if is_multiplayer:
		_send_end_turn_check_events()

	# End current turn
	end_current_turn()

	# In multiplayer, send turn end signal to opponent
	if is_multiplayer:
		NetworkManager.send_turn_end_signal()
		is_my_turn = false
		log_panel.add_with_color("Waiting for opponent...", LogPanel.COLOR_NORMAL)
	else:
		# Single player - start opponent turn
		await get_tree().create_timer(0.5).timeout
		execute_opponent_turn()

func end_current_turn() -> void:
	is_turn_active = false
	GameManager.end_turn()
	log_panel.add("Turn ended")

func execute_opponent_turn() -> void:
	log_panel.add_with_color("Opponent's turn", LogPanel.COLOR_NORMAL)
	current_turn_player_id = opponent_player.get_id()

	# Add resources
	_add_turn_resources(opponent_player)
	opponent_visual.update_display()

	GameManager.start_turn(opponent_player.get_id())

	# Wait before playing
	await get_tree().create_timer(1.0).timeout

	# AI plays cards
	await _ai_play_cards()

	# End opponent turn
	await get_tree().create_timer(1.0).timeout
	start_player_turn()

func start_player_turn() -> void:
	current_turn_player_id = local_player.get_id()
	is_turn_active = true

	# Add resources
	_add_turn_resources(local_player)
	player_visual.update_display()

	# Draw a card
	_draw_card(local_player, player_visual)

	GameManager.start_turn(local_player.get_id())
	log_panel.add_with_color("Your turn!", LogPanel.COLOR_NORMAL)

func _add_turn_resources(player: Player) -> void:
	var strength := player.strength
	strength[CardType.Type.FIRE] += 1
	strength[CardType.Type.WATER] += 1
	strength[CardType.Type.AIR] += 1
	strength[CardType.Type.EARTH] += 1
	strength[CardType.Type.OTHER] += 1

func _on_player_hand_card_clicked(card_visual: CardVisual) -> void:
	if not is_turn_active:
		return

	# Check if it's player's turn in multiplayer
	if is_multiplayer and not is_my_turn:
		log_panel.add_with_color("Wait for your turn!", LogPanel.COLOR_DAMAGE)
		return

	var card := card_visual.get_card()
	if not can_play_card(card, local_player):
		log_panel.add_with_color("Not enough resources!", LogPanel.COLOR_DAMAGE)
		return

	# Deselect previous card
	if selected_card != null and selected_card != card_visual:
		selected_card.set_selected(false)

	# Select this card
	selected_card = card_visual
	selected_card.set_selected(true)

	# Highlight available slots
	if not card.is_spell():
		var empty_slots := player_visual.get_empty_slot_indices()
		player_visual.highlight_all_slots(false)
		for slot_idx in empty_slots:
			player_visual.highlight_slot(slot_idx, true)

		awaiting_summon_slot = true
		log_panel.add("Select a slot to summon creature")
	else:
		# Spell - may need target
		opponent_visual.highlight_all_slots(true, true)
		awaiting_target = true
		log_panel.add("Select a target for the spell")

func _on_player_slot_clicked(slot: SlotVisual) -> void:
	if not awaiting_summon_slot:
		return

	if selected_card == null:
		return

	var card := selected_card.get_card()
	if card.is_spell():
		return

	if not slot.is_empty():
		log_panel.add_with_color("Slot is occupied!", LogPanel.COLOR_DAMAGE)
		return

	# Summon creature
	summon_creature(card, slot.get_slot_index())

func _on_opponent_slot_clicked(slot: SlotVisual) -> void:
	if not awaiting_target:
		return

	if selected_card == null:
		return

	var card := selected_card.get_card()
	if not card.is_spell():
		return

	# Cast spell on target
	cast_spell(card, slot.get_slot_index())

func summon_creature(card: Card, slot_index: int) -> void:
	# Deduct costs
	if not _deduct_card_costs(card, local_player):
		log_panel.add_with_color("Cannot play card!", LogPanel.COLOR_DAMAGE)
		return

	# Play summon drop sound
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.SUMMON_DROP)

	# Remove card from hand
	player_visual.remove_card_from_hand(selected_card)
	player_hand.erase(card)

	# Create creature instance
	var creature: BaseCreature = CreatureFactory.get_creature_class(
		card.get_name(),
		self,
		card,
		null,  # card_image
		slot_index,
		player_visual,
		opponent_visual
	)

	# Add to slot
	var card_visual := CardVisual.new()
	card_visual.setup_card(card, "small")
	card_visual.set_creature(creature)

	var slot := player_visual.get_slot_at_index(slot_index)
	slot.set_card(card_visual)

	# Update displays
	player_visual.update_display()

	# Log summon
	log_panel.add_summon(card.get_name(), local_player.get_name(), slot_index)
	GameManager.emit_signal("card_summoned", card, local_player.get_id(), slot_index)

	# Send network event in multiplayer
	if is_multiplayer:
		var event := NetworkEvent.create_with_slot(
			NetworkEvent.EventType.CARD_SUMMONED,
			slot_index,
			card.get_name(),
			NetworkManager.local_player_id
		)
		event.life = card.get_life()
		event.attack = card.get_attack()
		NetworkManager.send_network_event(event)
		print("GameController: Sent CARD_SUMMONED event for %s at slot %d" % [card.get_name(), slot_index])

	# Clear selection
	_clear_selection()

func cast_spell(card: Card, target_slot: int) -> void:
	# Deduct costs
	if not _deduct_card_costs(card, local_player):
		log_panel.add_with_color("Cannot cast spell!", LogPanel.COLOR_DAMAGE)
		return

	# Remove card from hand
	player_visual.remove_card_from_hand(selected_card)
	player_hand.erase(card)

	# Create spell instance
	var _spell: BaseSpell = SpellFactory.get_spell_class(
		card.get_name(),
		self,
		card,
		null,  # card_image
		player_visual,
		opponent_visual
	)

	# Cast spell (basic implementation)
	var target_slot_visual := opponent_visual.get_slot_at_index(target_slot)
	var target_creature := target_slot_visual.get_creature() if target_slot_visual else null

	# Log spell
	log_panel.add_spell(card.get_name(), local_player.get_name())

	# Basic damage spell effect
	var damage := 5  # Default spell damage
	if target_creature:
		target_creature.take_damage(damage, local_player)
		log_panel.add_damage(target_creature.get_name(), damage)

		if target_creature.get_life() <= 0:
			log_panel.add_death(target_creature.get_name())
			target_slot_visual.remove_card()

	# Update displays
	player_visual.update_display()
	opponent_visual.update_display()

	# Send network event in multiplayer
	if is_multiplayer:
		var event := NetworkEvent.new(NetworkEvent.EventType.SPELL_CAST, NetworkManager.local_player_id)
		event.spell_name = card.get_name()
		event.slot = target_slot
		event.caster = local_player.get_name()
		event.spell_target_card_name = target_creature.get_name() if target_creature else ""
		event.targeted_card_owner_id = opponent_player.get_id()
		event.damage_via_spell = true
		NetworkManager.send_network_event(event)
		print("GameController: Sent SPELL_CAST event for %s targeting slot %d" % [card.get_name(), target_slot])

	# Clear selection
	_clear_selection()

func _ai_play_cards() -> void:
	# Simple AI: play first affordable card
	var hand: Array = opponent_hand
	var played_count: int = 0

	for card in hand.duplicate():
		if played_count >= 2:
			break

		if not can_play_card(card, opponent_player):
			continue

		if not card.is_spell():
			# Find empty slot
			var empty_slots := opponent_visual.get_empty_slot_indices()
			if empty_slots.size() > 0:
				var slot_idx: int = empty_slots[0]
				_ai_summon_creature(card, slot_idx)
				played_count += 1
				await get_tree().create_timer(1.0).timeout
		else:
			# Spell - target random player slot
			var occupied_slots := player_visual.get_occupied_slot_indices()
			if occupied_slots.size() > 0:
				var target_idx: int = occupied_slots[randi() % occupied_slots.size()]
				_ai_cast_spell(card, target_idx)
				played_count += 1
				await get_tree().create_timer(1.0).timeout

func _ai_summon_creature(card: Card, slot_index: int) -> void:
	# Deduct costs
	_deduct_card_costs(card, opponent_player)

	# Remove from hand
	opponent_hand.erase(card)

	# Create creature
	var creature: BaseCreature = CreatureFactory.get_creature_class(
		card.get_name(),
		self,
		card,
		null,
		slot_index,
		opponent_visual,
		player_visual
	)

	# Add to slot
	var card_visual := CardVisual.new()
	card_visual.setup_card(card, "small")
	card_visual.set_creature(creature)

	var slot := opponent_visual.get_slot_at_index(slot_index)
	slot.set_card(card_visual)

	# Update and log
	opponent_visual.update_display()
	log_panel.add_summon(card.get_name(), opponent_player.get_name(), slot_index)

func _ai_cast_spell(card: Card, target_slot: int) -> void:
	# Deduct costs
	_deduct_card_costs(card, opponent_player)

	# Remove from hand
	opponent_hand.erase(card)

	# Cast on target
	var target_slot_visual := player_visual.get_slot_at_index(target_slot)
	var target_creature := target_slot_visual.get_creature() if target_slot_visual else null

	log_panel.add_spell(card.get_name(), opponent_player.get_name())

	if target_creature:
		var damage := 5
		target_creature.take_damage(damage, opponent_player)
		log_panel.add_damage(target_creature.get_name(), damage)

		if target_creature.get_life() <= 0:
			log_panel.add_death(target_creature.get_name())
			target_slot_visual.remove_card()

	opponent_visual.update_display()
	player_visual.update_display()

func can_play_card(card: Card, player: Player) -> bool:
	var card_type: CardType.Type = card.get_type()
	var card_cost: int = card.get_cost()
	var player_strength: int = player.get_strength(card_type)

	return player_strength >= card_cost

func _deduct_card_costs(card: Card, player: Player) -> bool:
	if not can_play_card(card, player):
		return false

	var card_type: CardType.Type = card.get_type()
	var card_cost: int = card.get_cost()
	player.decrement_strength(card_type, card_cost)

	return true

func _clear_selection() -> void:
	if selected_card:
		selected_card.set_selected(false)
		selected_card = null

	player_visual.highlight_all_slots(false)
	opponent_visual.highlight_all_slots(false)

	awaiting_summon_slot = false
	awaiting_target = false

# =============================================================================
# NETWORK EVENT HANDLING
# =============================================================================

# Main network event handler - routes to specific handlers
func _on_network_event_received(event: NetworkEvent) -> void:
	if event == null:
		push_warning("GameController: Received null network event")
		return

	print("GameController: Processing network event: %s" % event.get_event_type_string())

	# Route to appropriate handler based on event type
	match event.get_event_type():
		NetworkEvent.EventType.CARD_SUMMONED:
			_handle_remote_card_summoned(event)

		NetworkEvent.EventType.CARD_ATTACK:
			_handle_remote_card_attack(event)

		NetworkEvent.EventType.SPELL_CAST:
			_handle_remote_spell_cast(event)

		NetworkEvent.EventType.CARD_START_TURN_CHECK:
			_handle_remote_start_turn_check(event)

		NetworkEvent.EventType.CARD_END_TURN_CHECK:
			_handle_remote_end_turn_check(event)

		NetworkEvent.EventType.PLAYER_INCR_STRENGTH_ALL:
			_handle_remote_strength_change(event)

		NetworkEvent.EventType.GAME_OVER:
			_handle_remote_game_over(event)

		_:
			push_warning("GameController: Unknown event type: %s" % event.get_event_type_string())

# Handle remote card summon
func _handle_remote_card_summoned(event: NetworkEvent) -> void:
	var card_name: String = event.get_card_name()
	var slot_index: int = event.get_slot()
	var life: int = event.get_life()
	var attack: int = event.get_attack()

	print("GameController: Remote card summoned - %s at slot %d" % [card_name, slot_index])

	# Create card for opponent
	var card := Card.new()
	card.set_name(card_name)
	card.set_spell(false)
	card.set_life(life)
	card.set_attack(attack)
	card.set_type(CardType.Type.FIRE)  # Default type

	# Create creature instance
	var creature: BaseCreature = CreatureFactory.get_creature_class(
		card_name,
		self,
		card,
		null,
		slot_index,
		opponent_visual,
		player_visual
	)

	# Add to opponent's slot
	var card_visual := CardVisual.new()
	card_visual.setup_card(card, "small")
	card_visual.set_creature(creature)

	var slot := opponent_visual.get_slot_at_index(slot_index)
	slot.set_card(card_visual)

	# Trigger on_summoned effect
	if creature and creature.has_method("on_summoned"):
		creature.on_summoned()

	# Update display
	opponent_visual.update_display()

	# Log
	log_panel.add_summon(card_name, opponent_player.get_name(), slot_index)

# Handle remote card attack
func _handle_remote_card_attack(event: NetworkEvent) -> void:
	var slot_index: int = event.get_slot()
	var attack_value: int = event.get_attack()

	print("GameController: Remote card attack from slot %d" % slot_index)

	# Get attacking creature
	var attacker_slot := opponent_visual.get_slot_at_index(slot_index)
	if not attacker_slot or attacker_slot.is_empty():
		push_warning("GameController: No creature at slot %d to attack" % slot_index)
		return

	var attacker := attacker_slot.get_creature()
	if not attacker:
		return

	# Trigger on_attack effect
	if attacker.has_method("on_attack"):
		attacker.on_attack()

	# Apply attack (basic implementation - direct player damage)
	local_player.set_life(local_player.get_life() - attack_value)
	player_visual.update_display()

	# Play damage sound
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.NEGATIVE_EFFECT)

	# Log
	log_panel.add_with_color("%s attacks for %d damage!" % [attacker.get_name(), attack_value], LogPanel.COLOR_DAMAGE)

	# Check for game over
	if local_player.get_life() <= 0:
		GameManager.game_over.emit(opponent_player.get_id())

# Handle remote spell cast
func _handle_remote_spell_cast(event: NetworkEvent) -> void:
	var spell_name: String = event.get_spell_name()
	var target_slot: int = event.get_slot()
	var caster_name: String = event.get_caster()

	print("GameController: Remote spell cast - %s targeting slot %d" % [spell_name, target_slot])

	# Create spell instance
	var card := Card.new()
	card.set_name(spell_name)
	card.set_spell(true)

	var _spell: BaseSpell = SpellFactory.get_spell_class(
		spell_name,
		self,
		card,
		null,  # card_image
		opponent_visual,
		player_visual
	)

	# Get target
	var target_slot_visual := player_visual.get_slot_at_index(target_slot)
	var target_creature := target_slot_visual.get_creature() if target_slot_visual else null

	# Log spell
	log_panel.add_spell(spell_name, caster_name)

	# Execute spell effect (basic damage)
	if target_creature and event.is_damage_via_spell():
		var damage := 5  # Default spell damage
		target_creature.take_damage(damage, opponent_player)
		log_panel.add_damage(target_creature.get_name(), damage)

		if target_creature.get_life() <= 0:
			log_panel.add_death(target_creature.get_name())
			target_slot_visual.remove_card()

	# Update displays
	player_visual.update_display()
	opponent_visual.update_display()

# Handle remote start turn check
func _handle_remote_start_turn_check(event: NetworkEvent) -> void:
	var slot_index: int = event.get_slot()

	print("GameController: Remote start turn check for slot %d" % slot_index)

	# Get creature at slot
	var slot := opponent_visual.get_slot_at_index(slot_index)
	if not slot or slot.is_empty():
		return

	var creature := slot.get_creature()
	if not creature:
		return

	# Trigger on_start_turn effect
	if creature.has_method("on_start_turn"):
		creature.on_start_turn()

	# Update display
	opponent_visual.update_display()

# Handle remote end turn check
func _handle_remote_end_turn_check(event: NetworkEvent) -> void:
	var slot_index: int = event.get_slot()

	print("GameController: Remote end turn check for slot %d" % slot_index)

	# Get creature at slot
	var slot := opponent_visual.get_slot_at_index(slot_index)
	if not slot or slot.is_empty():
		return

	var creature := slot.get_creature()
	if not creature:
		return

	# Trigger on_end_turn effect
	if creature.has_method("on_end_turn"):
		creature.on_end_turn()

	# Update display
	opponent_visual.update_display()

# Handle remote strength change
func _handle_remote_strength_change(event: NetworkEvent) -> void:
	var type_affected: int = event.get_type_strength_affected()
	var strength_change: int = event.get_strength_affected()

	print("GameController: Remote strength change - type %d by %d" % [type_affected, strength_change])

	# Apply strength change to opponent
	if type_affected >= 0 and type_affected < CardType.Type.size():
		opponent_player.strength[type_affected] += strength_change
		opponent_visual.update_display()

		var type_name := CardType.get_type_name(type_affected)
		log_panel.add("Opponent %s strength changed by %d" % [type_name, strength_change])

# Handle remote game over
func _handle_remote_game_over(event: NetworkEvent) -> void:
	print("GameController: Remote game over event")

	var winner_id: String = event.player_data.get("winner_id", "")

	if winner_id == local_player.get_id():
		log_panel.add_game_over(local_player.get_name())
	elif winner_id == opponent_player.get_id():
		log_panel.add_game_over(opponent_player.get_name())
	else:
		log_panel.add_game_over("Unknown")

	is_turn_active = false
	is_my_turn = false

# =============================================================================
# NETWORK TURN CONTROL
# =============================================================================

# Called when multiplayer turn starts
func _on_multiplayer_turn_started() -> void:
	print("GameController: Multiplayer turn started")

	is_my_turn = true
	is_turn_active = true

	# Send start turn check events for all player cards
	_send_start_turn_check_events()

	# Add resources
	_add_turn_resources(local_player)
	player_visual.update_display()

	# Draw a card
	_draw_card(local_player, player_visual)

	# Update UI
	log_panel.add_with_color("Your turn!", LogPanel.COLOR_NORMAL)

	# Enable player input (already enabled by is_my_turn = true)
	print("GameController: Player input enabled")

# Called when multiplayer turn ends
func _on_multiplayer_turn_ended() -> void:
	print("GameController: Multiplayer turn ended")

	is_my_turn = false
	is_turn_active = false

	# Update UI
	log_panel.add_with_color("Opponent's turn...", LogPanel.COLOR_NORMAL)

	# Disable player input (already disabled by is_my_turn = false)
	print("GameController: Player input disabled")

# Send start turn check events for all player cards
func _send_start_turn_check_events() -> void:
	print("GameController: Sending start turn check events")

	for i in range(7):  # Assuming 7 slots
		var slot := player_visual.get_slot_at_index(i)
		if slot and not slot.is_empty():
			var creature := slot.get_creature()
			if creature:
				# Trigger local effect
				if creature.has_method("on_start_turn"):
					creature.on_start_turn()

				# Send network event
				var event := NetworkEvent.new(NetworkEvent.EventType.CARD_START_TURN_CHECK, NetworkManager.local_player_id)
				event.slot = i
				event.card_name = creature.get_name()
				NetworkManager.send_network_event(event)

	player_visual.update_display()

# Send end turn check events for all player cards
func _send_end_turn_check_events() -> void:
	print("GameController: Sending end turn check events")

	for i in range(7):  # Assuming 7 slots
		var slot := player_visual.get_slot_at_index(i)
		if slot and not slot.is_empty():
			var creature := slot.get_creature()
			if creature:
				# Trigger local effect
				if creature.has_method("on_end_turn"):
					creature.on_end_turn()

				# Send network event
				var event := NetworkEvent.new(NetworkEvent.EventType.CARD_END_TURN_CHECK, NetworkManager.local_player_id)
				event.slot = i
				event.card_name = creature.get_name()
				NetworkManager.send_network_event(event)

	player_visual.update_display()

# =============================================================================
# GAMEMANAGER SIGNAL HANDLERS
# =============================================================================

func _on_game_over(winner_id: String) -> void:
	is_turn_active = false
	is_my_turn = false

	var winner_name := "Unknown"
	if winner_id == local_player.get_id():
		winner_name = local_player.get_name()
	elif winner_id == opponent_player.get_id():
		winner_name = opponent_player.get_name()

	log_panel.add_game_over(winner_name)

	# Show victory/defeat screen
	show_victory_defeat_screen(winner_id)

	# Send game over event in multiplayer
	if is_multiplayer:
		var event := NetworkEvent.new(NetworkEvent.EventType.GAME_OVER, NetworkManager.local_player_id)
		event.player_data["winner_id"] = winner_id
		NetworkManager.send_network_event(event)

func _on_turn_started(_player_id: String) -> void:
	pass  # Already handled in turn methods

func _on_card_summoned(_card: Card, _player_id: String, _slot: int) -> void:
	pass  # Already logged in summon methods

# =============================================================================
# UI CREATION AND MANAGEMENT
# =============================================================================

func _create_victory_defeat_screen() -> void:
	"""Create the victory/defeat screen overlay."""
	victory_defeat_screen = Panel.new()
	victory_defeat_screen.custom_minimum_size = Vector2(400, 300)
	victory_defeat_screen.position = Vector2(312, 234)  # Center of 1024x768
	victory_defeat_screen.visible = false
	victory_defeat_screen.z_index = 200
	add_child(victory_defeat_screen)

	# Dark overlay background
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.8)
	overlay.size = Vector2(1024, 768)
	overlay.position = Vector2(-312, -234)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	victory_defeat_screen.add_child(overlay)

	# Title label
	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "VICTORY!"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	title_label.position = Vector2(50, 40)
	title_label.size = Vector2(300, 60)
	victory_defeat_screen.add_child(title_label)

	# Winner label
	var winner_label := Label.new()
	winner_label.name = "WinnerLabel"
	winner_label.text = "Player wins!"
	winner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	winner_label.add_theme_font_size_override("font_size", 24)
	winner_label.position = Vector2(50, 120)
	winner_label.size = Vector2(300, 40)
	victory_defeat_screen.add_child(winner_label)

	# Replay button
	var replay_button := Button.new()
	replay_button.text = "Play Again"
	replay_button.position = Vector2(100, 180)
	replay_button.size = Vector2(200, 40)
	replay_button.pressed.connect(_on_replay_pressed)
	victory_defeat_screen.add_child(replay_button)

	# Menu button
	var menu_button := Button.new()
	menu_button.text = "Return to Menu"
	menu_button.position = Vector2(100, 230)
	menu_button.size = Vector2(200, 40)
	menu_button.pressed.connect(_on_return_to_menu_pressed)
	victory_defeat_screen.add_child(menu_button)

func _create_pause_menu() -> void:
	"""Create the pause menu overlay."""
	pause_menu = Panel.new()
	pause_menu.custom_minimum_size = Vector2(300, 350)
	pause_menu.position = Vector2(362, 209)  # Center of 1024x768
	pause_menu.visible = false
	pause_menu.z_index = 150
	add_child(pause_menu)

	# Dark overlay background
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.size = Vector2(1024, 768)
	overlay.position = Vector2(-362, -209)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu.add_child(overlay)

	# Title
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.position = Vector2(50, 30)
	title.size = Vector2(200, 40)
	pause_menu.add_child(title)

	# Resume button
	var resume_button := Button.new()
	resume_button.text = "Resume"
	resume_button.position = Vector2(50, 90)
	resume_button.size = Vector2(200, 40)
	resume_button.pressed.connect(toggle_pause_menu)
	pause_menu.add_child(resume_button)

	# Settings button
	var settings_button := Button.new()
	settings_button.text = "Settings"
	settings_button.position = Vector2(50, 140)
	settings_button.size = Vector2(200, 40)
	settings_button.pressed.connect(_on_pause_settings_pressed)
	pause_menu.add_child(settings_button)

	# Forfeit button
	var forfeit_button := Button.new()
	forfeit_button.text = "Forfeit"
	forfeit_button.position = Vector2(50, 190)
	forfeit_button.size = Vector2(200, 40)
	forfeit_button.pressed.connect(_on_forfeit_pressed)
	pause_menu.add_child(forfeit_button)

	# Quit button
	var quit_button := Button.new()
	quit_button.text = "Quit to Menu"
	quit_button.position = Vector2(50, 240)
	quit_button.size = Vector2(200, 40)
	quit_button.pressed.connect(_on_pause_quit_pressed)
	pause_menu.add_child(quit_button)

func _create_turn_timer() -> void:
	"""Create the turn timer display."""
	turn_timer_label = Label.new()
	turn_timer_label.text = "Turn: 0:00"
	turn_timer_label.add_theme_font_size_override("font_size", 18)
	turn_timer_label.add_theme_color_override("font_color", Color(1, 1, 1))
	turn_timer_label.position = Vector2(10, 380)
	turn_timer_label.size = Vector2(150, 30)
	add_child(turn_timer_label)

func _create_fps_counter() -> void:
	"""Create the FPS counter display."""
	fps_counter_label = Label.new()
	fps_counter_label.text = "FPS: 60"
	fps_counter_label.add_theme_font_size_override("font_size", 14)
	fps_counter_label.add_theme_color_override("font_color", Color(0, 1, 0))
	fps_counter_label.position = Vector2(10, 10)
	fps_counter_label.size = Vector2(100, 25)
	fps_counter_label.visible = false
	add_child(fps_counter_label)

func _create_tooltip_panel() -> void:
	"""Create the card tooltip panel."""
	tooltip_panel = Panel.new()
	tooltip_panel.custom_minimum_size = Vector2(250, 200)
	tooltip_panel.visible = false
	tooltip_panel.z_index = 100
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tooltip_panel)

	var vbox := VBoxContainer.new()
	vbox.position = Vector2(10, 10)
	vbox.size = Vector2(230, 180)
	tooltip_panel.add_child(vbox)

	# Card name
	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
	vbox.add_child(name_label)

	# Card cost
	var cost_label := Label.new()
	cost_label.name = "CostLabel"
	cost_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(cost_label)

	# Card stats (for creatures)
	var stats_label := Label.new()
	stats_label.name = "StatsLabel"
	stats_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(stats_label)

	# Card description
	var desc_label := Label.new()
	desc_label.name = "DescLabel"
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(230, 0)
	vbox.add_child(desc_label)

func show_victory_defeat_screen(winner_id: String) -> void:
	"""Show the victory/defeat screen with animation."""
	if not victory_defeat_screen:
		return

	var is_victory: bool = winner_id == local_player.get_id()
	var title_label: Label = victory_defeat_screen.get_node("TitleLabel") as Label
	var winner_label: Label = victory_defeat_screen.get_node("WinnerLabel") as Label

	if is_victory:
		title_label.text = "VICTORY!"
		title_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
		winner_label.text = "You win!"
		# Play victory sound
		if SoundManager:
			SoundManager.play_sound(SoundTypes.Sound.GAMEOVER)
		# Spawn confetti particles
		_spawn_confetti()
	else:
		title_label.text = "DEFEAT"
		title_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		winner_label.text = opponent_player.get_name() + " wins!"
		# Darken screen
		var overlay := victory_defeat_screen.get_child(0) as ColorRect
		overlay.color = Color(0, 0, 0, 0.9)

	# Animate entrance
	victory_defeat_screen.modulate.a = 0.0
	victory_defeat_screen.scale = Vector2(0.8, 0.8)
	victory_defeat_screen.visible = true

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(victory_defeat_screen, "modulate:a", 1.0, 0.5)
	tween.tween_property(victory_defeat_screen, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _spawn_confetti() -> void:
	"""Spawn confetti particles for victory animation."""
	for i in range(50):
		var confetti := ColorRect.new()
		confetti.size = Vector2(8, 8)
		confetti.color = Color(randf(), randf(), randf())
		confetti.position = Vector2(randf_range(0, 1024), -20)
		add_child(confetti)

		var tween := create_tween()
		var end_pos := Vector2(randf_range(0, 1024), randf_range(600, 800))
		var duration := randf_range(1.5, 2.5)
		tween.tween_property(confetti, "position", end_pos, duration)
		tween.tween_callback(confetti.queue_free)

func toggle_pause_menu() -> void:
	"""Toggle the pause menu."""
	is_paused = not is_paused
	pause_menu.visible = is_paused
	get_tree().paused = is_paused

func show_card_tooltip(card: Card, mouse_pos: Vector2) -> void:
	"""Show tooltip for a card."""
	if not tooltip_panel or not card:
		return

	var name_label := tooltip_panel.get_node("VBoxContainer/NameLabel") as Label
	var cost_label := tooltip_panel.get_node("VBoxContainer/CostLabel") as Label
	var stats_label := tooltip_panel.get_node("VBoxContainer/StatsLabel") as Label
	var desc_label := tooltip_panel.get_node("VBoxContainer/DescLabel") as Label

	name_label.text = card.get_name()
	cost_label.text = "Cost: %s" % card.get_cost_string()

	if not card.is_spell():
		# This is a creature card, show attack and life stats
		stats_label.text = "ATK: %d  HP: %d" % [card.get_attack(), card.get_life()]
		stats_label.visible = true
	else:
		stats_label.visible = false

	desc_label.text = card.get_desc() if card.has_method("get_desc") else ""

	# Position tooltip near mouse
	tooltip_panel.position = mouse_pos + Vector2(15, 15)

	# Keep tooltip on screen
	if tooltip_panel.position.x + tooltip_panel.size.x > 1024:
		tooltip_panel.position.x = mouse_pos.x - tooltip_panel.size.x - 15
	if tooltip_panel.position.y + tooltip_panel.size.y > 768:
		tooltip_panel.position.y = 768 - tooltip_panel.size.y

	tooltip_panel.visible = true

func hide_card_tooltip() -> void:
	"""Hide the card tooltip."""
	if tooltip_panel:
		tooltip_panel.visible = false

# =============================================================================
# PAUSE MENU CALLBACKS
# =============================================================================

func _on_pause_settings_pressed() -> void:
	"""Open settings from pause menu."""
	# TODO: Implement settings menu overlay
	print("Settings pressed - not yet implemented")

func _on_forfeit_pressed() -> void:
	"""Forfeit the current game."""
	# Show confirmation dialog
	var confirm_dialog := ConfirmationDialog.new()
	confirm_dialog.dialog_text = "Are you sure you want to forfeit?"
	confirm_dialog.confirmed.connect(_do_forfeit)
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _do_forfeit() -> void:
	"""Actually forfeit the game."""
	is_paused = false
	pause_menu.visible = false
	get_tree().paused = false

	# Opponent wins
	show_victory_defeat_screen(opponent_player.get_id())

func _on_pause_quit_pressed() -> void:
	"""Quit to main menu from pause."""
	is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

# =============================================================================
# VICTORY/DEFEAT SCREEN CALLBACKS
# =============================================================================

func _on_replay_pressed() -> void:
	"""Replay the game."""
	get_tree().reload_current_scene()

func _on_return_to_menu_pressed() -> void:
	"""Return to main menu."""
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
