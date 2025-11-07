extends RefCounted
class_name BaseFunctions

var card: Card = null
var card_image = null
var game = null
var slot_index: int = -1

var opposing_player: Player = null
var owner_player: Player = null

var owner = null
var opponent = null

var is_spell: bool = false
var must_skip_next_attack: bool = false

# Additional variables for creature/spell scripts
var creature_card: Card = null
var game_state = null
var opponent_cards: Array = []
var owner_cards: Array = []

func inflict_damage(target_card, amount: int) -> bool:
	if target_card == null or card_image == null:
		return false

	var damage: int = amount

	if target_card.has_method("decrement_life"):
		target_card.decrement_life(damage)

		if game != null and game.has_method("log_message"):
			game.log_message("%s dealt %d damage to %s" % [
				card_image.get_card().get_cardname(),
				damage,
				target_card.get_card().get_name()
			])

		if target_card.get_card().get_life() <= 0:
			return true

	return false

func inflict_damage_to_player(target_player, damage_value: int) -> void:
	if target_player == null:
		return

	var value: int = damage_value
	var target_player_image = target_player

	if game != null and game.has_method("get_player_image_by_id"):
		var player_id: String = target_player.get_id() if target_player.has_method("get_id") else ""
		target_player_image = game.get_player_image_by_id(player_id)

	if target_player_image != null and target_player_image.has_method("get_slot_cards"):
		var owned_cards: Array = target_player_image.get_slot_cards()
		var opposing_cards: Array = []

		if game != null and game.has_method("get_opposing_player_image"):
			var opposing_pi = game.get_opposing_player_image(target_player.get_id())
			if opposing_pi != null and opposing_pi.has_method("get_slot_cards"):
				opposing_cards = opposing_pi.get_slot_cards()

		for index in range(6):
			if index < opposing_cards.size() and opposing_cards[index] != null:
				var opposing_card_name: String = opposing_cards[index].get_card().get_name().to_lower()

				if opposing_card_name == "justicar":
					if index < owned_cards.size() and owned_cards[index] == null:
						value += 2

				if opposing_card_name == "vampiremystic":
					opposing_cards[index].get_card().increment_attack(2)

				if opposing_card_name == "iceguard":
					value = int(value / 2)

			if index < owned_cards.size() and owned_cards[index] != null:
				var owned_card_name: String = owned_cards[index].get_card().get_name().to_lower()

				if owned_card_name == "chastiser":
					owned_cards[index].get_card().increment_attack(2)

				if owned_card_name == "whiteelephant":
					damage_slot(owned_cards[index], index, target_player_image, value)
					return

	if card != null and card.get_name().to_lower() == "goblinsaboteur":
		remove_random_cheapest_card(opposing_player)

	if target_player.has_method("decrement_life"):
		target_player.decrement_life(value)

	if game != null and game.has_method("log_message"):
		game.log_message("%s dealt %d damage to player" % [
			card.get_cardname() if card != null else "Unknown",
			value
		])

	if target_player.has_method("get_life") and target_player.get_life() < 1:
		if game != null and game.has_method("game_over"):
			game.game_over(target_player.get_id())

func heal_card(target_card, amount: int) -> void:
	if target_card == null:
		return

	var card_ref = target_card.get_card() if target_card.has_method("get_card") else target_card

	if card_ref != null and card_ref.has_method("increment_life"):
		var max_life: int = card_ref.get_original_life()
		var current_life: int = card_ref.get_life()
		var heal_amount: int = min(amount, max_life - current_life)

		if heal_amount > 0:
			card_ref.increment_life(heal_amount)

			if game != null and game.has_method("log_message"):
				game.log_message("%s healed for %d" % [
					card_ref.get_cardname(),
					heal_amount
				])

func heal_player(target_player, amount: int) -> void:
	if target_player == null:
		return

	if target_player.has_method("increment_life"):
		target_player.increment_life(amount)

		if game != null and game.has_method("log_message"):
			game.log_message("Player healed for %d" % amount)

func kill_card(target_card) -> void:
	if target_card == null:
		return

	if target_card.has_method("get_card"):
		var card_ref: Card = target_card.get_card()
		if card_ref != null:
			card_ref.set_life(0)

	if game != null and game.has_method("dispose_card"):
		game.dispose_card(target_card)

func get_random_enemy_creature():
	if opponent == null or not opponent.has_method("get_slot_cards"):
		return null

	var enemy_cards: Array = opponent.get_slot_cards()
	var valid_targets: Array = []

	for card_img in enemy_cards:
		if card_img != null:
			valid_targets.append(card_img)

	if valid_targets.size() == 0:
		return null

	var random_index: int = randi() % valid_targets.size()
	return valid_targets[random_index]

func get_lowest_attack_enemy():
	if opponent == null or not opponent.has_method("get_slot_cards"):
		return null

	var enemy_cards: Array = opponent.get_slot_cards()
	var lowest_card = null
	var lowest_attack: int = 999999

	for card_img in enemy_cards:
		if card_img != null and card_img.has_method("get_card"):
			var enemy_card: Card = card_img.get_card()
			var attack: int = enemy_card.get_attack()
			if attack < lowest_attack:
				lowest_attack = attack
				lowest_card = card_img

	return lowest_card

func get_highest_attack_enemy():
	if opponent == null or not opponent.has_method("get_slot_cards"):
		return null

	var enemy_cards: Array = opponent.get_slot_cards()
	var highest_card = null
	var highest_attack: int = -1

	for card_img in enemy_cards:
		if card_img != null and card_img.has_method("get_card"):
			var enemy_card: Card = card_img.get_card()
			var attack: int = enemy_card.get_attack()
			if attack > highest_attack:
				highest_attack = attack
				highest_card = card_img

	return highest_card

func count_owner_creatures() -> int:
	if owner == null or not owner.has_method("get_slot_cards"):
		return 0

	var owner_cards: Array = owner.get_slot_cards()
	var count: int = 0

	for card_img in owner_cards:
		if card_img != null:
			count += 1

	return count

func count_opponent_creatures() -> int:
	if opponent == null or not opponent.has_method("get_slot_cards"):
		return 0

	var opponent_cards: Array = opponent.get_slot_cards()
	var count: int = 0

	for card_img in opponent_cards:
		if card_img != null:
			count += 1

	return count

func heal_all(value: int) -> void:
	if owner == null or not owner.has_method("get_slot_cards"):
		return

	var owner_cards: Array = owner.get_slot_cards()
	for card_img in owner_cards:
		if card_img != null:
			heal_card(card_img, value)

func damage_slot(card_img, index: int, player_image, attack: int) -> void:
	if card_img == null:
		return

	var died: bool = inflict_damage(card_img, attack)

	if died:
		dispose_card_image(player_image, index)

func dispose_card_image(player_image, slot_idx: int, destroyed: bool = false) -> void:
	if player_image == null or not player_image.has_method("get_slot_cards"):
		return

	var cards: Array = player_image.get_slot_cards()

	if slot_idx < 0 or slot_idx >= cards.size():
		return

	var card_img = cards[slot_idx]
	if card_img == null:
		return

	if player_image.has_method("get_slots"):
		var slots: Array = player_image.get_slots()
		if slot_idx < slots.size() and slots[slot_idx] != null:
			slots[slot_idx].set_occupied(false)

	cards[slot_idx] = null

	if not destroyed and card_img.has_method("get_creature"):
		var creature = card_img.get_creature()
		if creature != null and creature.has_method("on_dying"):
			creature.on_dying()

	if card_img.has_method("queue_free"):
		card_img.queue_free()

func damage_neighbors(value: int) -> void:
	var neighbor_slots: Array = [slot_index - 1, slot_index + 1]
	damage_slots(neighbor_slots, owner, value)

func damage_all(player_image, value: int) -> void:
	var slots: Array = [0, 1, 2, 3, 4, 5]
	damage_slots(slots, player_image, value)

func damage_slots(indexes: Array, player_image, value: int) -> void:
	if player_image == null or not player_image.has_method("get_slot_cards"):
		return

	var cards: Array = player_image.get_slot_cards()

	for index in indexes:
		if index < 0 or index > 5:
			continue
		if index >= cards.size():
			continue

		var card_img = cards[index]
		if card_img == null:
			continue

		damage_slot(card_img, index, player_image, value)

func enhance_attack_neighboring(value: int) -> void:
	var neighbor_slots: Array = [slot_index - 1, slot_index + 1]
	enhance_attack_slots(neighbor_slots, owner, value)

func enhance_attack_all(player_image, value: int) -> void:
	var slots: Array = [0, 1, 2, 3, 4, 5]
	enhance_attack_slots(slots, player_image, value)

func enhance_attack_slots(slots: Array, player_image, value: int) -> void:
	if player_image == null or not player_image.has_method("get_slot_cards"):
		return

	var cards: Array = player_image.get_slot_cards()

	for index in slots:
		if index < 0 or index > 5 or index == slot_index:
			continue
		if index >= cards.size():
			continue

		var card_img = cards[index]
		if card_img == null:
			continue

		if card_img.has_method("get_card"):
			card_img.get_card().increment_attack(value)

func remove_random_cheapest_card(player: Player) -> void:
	if player == null:
		return

	var cards: Array = []
	var attempts: int = 0

	while (cards.size() < 1 and attempts < 10):
		var dice: Dice = Dice.new(1, 5)
		var roll: int = dice.roll()
		var type: CardType.Type = Player.TYPES[roll - 1]
		cards = player.get_cards(type)
		attempts += 1

	if cards.size() > 0:
		var card_to_remove = cards[0]
		cards.remove_at(0)

		if card_to_remove.has_method("queue_free"):
			card_to_remove.queue_free()

		if game != null and game.has_method("play_sound"):
			game.play_sound("negative_effect")
