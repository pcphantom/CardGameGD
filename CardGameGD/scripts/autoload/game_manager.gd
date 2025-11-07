extends Node

# GameManager Autoload Singleton
#
# Manages global game state and coordinates all game events.
# This replaces static variables and methods from Cards.java.
#
# Accessible globally via: GameManager.property_name or GameManager.method_name()

# Screen constants
const SCREEN_WIDTH: int = 1024
const SCREEN_HEIGHT: int = 768

# Game state properties
var screen_width: int = SCREEN_WIDTH
var screen_height: int = SCREEN_HEIGHT
var current_game = null
var player1 = null
var player2 = null
var is_turn_active: bool = false
var current_player_id: String = ""
var network_game = null

# Game log
var game_log: Array = []
var max_log_entries: int = 100

# Game signals
signal game_over(winner_id: String)
signal turn_started(player_id: String)
signal turn_ended(player_id: String)
signal card_summoned(card: Card, player_id: String, slot: int)
signal card_attacked(attacker: Card, target, damage: int)
signal spell_cast(spell: Card, caster_id: String)
signal player_damaged(player_id: String, damage: int)
signal creature_died(creature: Card, slot: int, player_id: String)

func _ready() -> void:
	print("GameManager: Initializing autoload singleton")
	reset_game()
	set_process(true)

func start_game(p1, p2) -> void:
	if p1 == null or p2 == null:
		push_error("GameManager.start_game(): Invalid player references")
		return

	player1 = p1
	player2 = p2

	current_player_id = ""
	if player1.has_method("get_player_info"):
		var p1_info = player1.get_player_info()
		if p1_info != null and p1_info.has_method("get_id"):
			current_player_id = p1_info.get_id()

	is_turn_active = true

	log_message("=== Game Started ===")
	if current_player_id != "":
		turn_started.emit(current_player_id)
		log_message("Turn: Player 1")

func end_turn() -> void:
	if not is_turn_active:
		return

	var previous_player_id: String = current_player_id

	turn_ended.emit(previous_player_id)

	if player1 != null and player2 != null:
		if player1.has_method("get_player_info") and player2.has_method("get_player_info"):
			var p1_info = player1.get_player_info()
			var p2_info = player2.get_player_info()

			if p1_info != null and p2_info != null:
				if p1_info.has_method("get_id") and p2_info.has_method("get_id"):
					var p1_id: String = p1_info.get_id()
					var p2_id: String = p2_info.get_id()

					if current_player_id == p1_id:
						current_player_id = p2_id
						log_message("Turn: Player 2")
					else:
						current_player_id = p1_id
						log_message("Turn: Player 1")

					turn_started.emit(current_player_id)

func handle_game_over(exception: GameOverException) -> void:
	if exception == null:
		push_error("GameManager.handle_game_over(): Null exception")
		return

	is_turn_active = false

	var died_player_id: String = exception.get_died_player_id()
	var winner_id: String = ""

	if player1 != null and player2 != null:
		if player1.has_method("get_player_info") and player2.has_method("get_player_info"):
			var p1_info = player1.get_player_info()
			var p2_info = player2.get_player_info()

			if p1_info != null and p2_info != null:
				if p1_info.has_method("get_id") and p2_info.has_method("get_id"):
					var p1_id: String = p1_info.get_id()
					var p2_id: String = p2_info.get_id()

					if died_player_id == p1_id:
						winner_id = p2_id
						log_message("=== Game Over: Player 2 Wins! ===")
					elif died_player_id == p2_id:
						winner_id = p1_id
						log_message("=== Game Over: Player 1 Wins! ===")
					else:
						log_message("=== Game Over: Unknown Winner ===")
						winner_id = ""

	game_over.emit(winner_id)

func log_message(message: String) -> void:
	if message.is_empty():
		return

	var timestamp: String = Time.get_time_string_from_system()
	var log_entry: String = "[%s] %s" % [timestamp, message]

	game_log.append(log_entry)

	if game_log.size() > max_log_entries:
		game_log.pop_front()

	print(log_entry)

func get_log_history() -> Array:
	return game_log.duplicate()

func clear_log() -> void:
	game_log.clear()
	log_message("Log cleared")

func reset_game() -> void:
	current_game = null
	player1 = null
	player2 = null
	is_turn_active = false
	current_player_id = ""
	network_game = null
	game_log.clear()

	log_message("GameManager: Game state reset")

func is_my_turn(player_id: String) -> bool:
	return is_turn_active and current_player_id == player_id

func get_current_player():
	if player1 != null and player2 != null:
		if player1.has_method("get_player_info"):
			var p1_info = player1.get_player_info()
			if p1_info != null and p1_info.has_method("get_id"):
				if p1_info.get_id() == current_player_id:
					return player1

		if player2.has_method("get_player_info"):
			var p2_info = player2.get_player_info()
			if p2_info != null and p2_info.has_method("get_id"):
				if p2_info.get_id() == current_player_id:
					return player2

	return null

func get_opposing_player(player_id: String):
	if player1 != null and player2 != null:
		if player1.has_method("get_player_info"):
			var p1_info = player1.get_player_info()
			if p1_info != null and p1_info.has_method("get_id"):
				if p1_info.get_id() == player_id:
					return player2

		if player2.has_method("get_player_info"):
			var p2_info = player2.get_player_info()
			if p2_info != null and p2_info.has_method("get_id"):
				if p2_info.get_id() == player_id:
					return player1

	return null

func emit_card_summoned(card: Card, player_id: String, slot: int) -> void:
	card_summoned.emit(card, player_id, slot)
	if card != null:
		log_message("Card summoned: %s at slot %d" % [card.get_cardname(), slot])

func emit_card_attacked(attacker: Card, target, damage: int) -> void:
	card_attacked.emit(attacker, target, damage)
	if attacker != null:
		var target_name: String = "Unknown"
		if target != null and target.has_method("get_cardname"):
			target_name = target.get_cardname()
		log_message("%s attacks %s for %d damage" % [attacker.get_cardname(), target_name, damage])

func emit_spell_cast(spell: Card, caster_id: String) -> void:
	spell_cast.emit(spell, caster_id)
	if spell != null:
		log_message("Spell cast: %s" % spell.get_cardname())

func emit_player_damaged(player_id: String, damage: int) -> void:
	player_damaged.emit(player_id, damage)
	log_message("Player damaged: %d damage" % damage)

func emit_creature_died(creature: Card, slot: int, player_id: String) -> void:
	creature_died.emit(creature, slot, player_id)
	if creature != null:
		log_message("Creature died: %s at slot %d" % [creature.get_cardname(), slot])

func get_player_by_id(player_id: String):
	if player1 != null and player1.has_method("get_player_info"):
		var p1_info = player1.get_player_info()
		if p1_info != null and p1_info.has_method("get_id"):
			if p1_info.get_id() == player_id:
				return player1

	if player2 != null and player2.has_method("get_player_info"):
		var p2_info = player2.get_player_info()
		if p2_info != null and p2_info.has_method("get_id"):
			if p2_info.get_id() == player_id:
				return player2

	return null
