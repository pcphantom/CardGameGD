extends RefCounted
class_name Utils

# Utils
#
# Utility functions for game operations, primarily for network event handling.
# Replaces Utils.java with static helper methods.

static func attack_with_network_event(creature, player: Player, index: int) -> void:
	if creature == null or player == null:
		push_error("Utils.attack_with_network_event(): Null creature or player")
		return

	if not creature.has_method("on_attack"):
		push_warning("Utils.attack_with_network_event(): Creature has no on_attack method")
		send_attack_network_event(player, index)
		return

	await creature.on_attack()

	if GameManager.network_game != null:
		send_attack_network_event(player, index)

static func send_attack_network_event(player: Player, index: int) -> void:
	if player == null:
		return

	if GameManager.network_game == null:
		return

	var player_id: String = player.get_id() if player.has_method("get_id") else ""

	if GameManager.network_game.has_method("send_attack_event"):
		GameManager.network_game.send_attack_event(player_id, index)

static func handle_game_over_exception(exception: GameOverException) -> void:
	if exception == null:
		push_error("Utils.handle_game_over_exception(): Null exception")
		return

	if GameManager.has_method("handle_game_over"):
		GameManager.handle_game_over(exception)
	else:
		push_error("Utils.handle_game_over_exception(): GameManager missing handle_game_over method")

static func is_valid_slot_index(index: int) -> bool:
	return index >= 0 and index <= 5

static func get_opponent_player(player_id: String):
	if GameManager.has_method("get_opposing_player"):
		return GameManager.get_opposing_player(player_id)
	return null

static func get_player_by_id(player_id: String):
	if GameManager.has_method("get_player_by_id"):
		return GameManager.get_player_by_id(player_id)
	return null

static func log_game_event(message: String) -> void:
	if GameManager.has_method("log_message"):
		GameManager.log_message(message)
	else:
		print(message)

static func clamp_value(value: int, min_value: int, max_value: int) -> int:
	return clampi(value, min_value, max_value)

static func random_range(min_value: int, max_value: int) -> int:
	return randi_range(min_value, max_value)

static func shuffle_array(array: Array) -> Array:
	var shuffled: Array = array.duplicate()
	shuffled.shuffle()
	return shuffled
