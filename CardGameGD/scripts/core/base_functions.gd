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

	# Java: target_card.decrementLife(this, damage, game) - CardImage needs 3 args
	if target_card.has_method("decrement_life"):
		target_card.decrement_life(self, damage, game)

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
					value = int(value / 2.0)

			if index < owned_cards.size() and owned_cards[index] != null:
				var owned_card_name: String = owned_cards[index].get_card().get_name().to_lower()

				if owned_card_name == "chastiser":
					owned_cards[index].get_card().increment_attack(2)

				if owned_card_name == "whiteelephant":
					damage_slot(owned_cards[index], index, target_player_image, value)
					return

	if card != null and card.get_name().to_lower() == "goblinsaboteur":
		remove_random_cheapest_card(opposing_player)

	# Java: targetPlayer.decrementLife(value, game)
	if target_player.has_method("decrement_life"):
		target_player.decrement_life(value, game)

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

	var owner_slot_cards: Array = owner.get_slot_cards()
	var count: int = 0

	for card_img in owner_slot_cards:
		if card_img != null:
			count += 1

	return count

func count_opponent_creatures() -> int:
	if opponent == null or not opponent.has_method("get_slot_cards"):
		return 0

	var opponent_slot_cards: Array = opponent.get_slot_cards()
	var count: int = 0

	for card_img in opponent_slot_cards:
		if card_img != null:
			count += 1

	return count

func heal_all(value: int) -> void:
	if owner == null or not owner.has_method("get_slot_cards"):
		return

	var owner_slot_cards: Array = owner.get_slot_cards()
	for card_img in owner_slot_cards:
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

# ============================================================================
# Missing methods from Java BaseFunctions (exact signatures)
# ============================================================================

## Java: protected void damageOpponent(int value)
func damage_opponent(value: int) -> void:
	inflict_damage_to_player(opponent, value)

## Java: protected void damagePlayer(PlayerImage pi, int value)
func damage_player(player_image, value: int) -> void:
	inflict_damage_to_player(player_image, value)

## Java: protected void damageAllExceptCurrentIndex(int attack, PlayerImage pi)
func damage_all_except_current_index(attack: int, player_image) -> void:
	if player_image == null or not player_image.has_method("get_slot_cards"):
		return

	var cards: Array = player_image.get_slot_cards()

	for index in range(6):
		if index == slot_index:
			continue
		if index >= cards.size():
			continue

		var card_img = cards[index]
		if card_img == null:
			continue

		damage_slot(card_img, index, player_image, attack)

## Java: protected void addCreature(String name, int index, SlotImage slot)
func add_creature(name: String, index: int, slot) -> void:
	if game == null or owner == null:
		push_error("BaseFunctions.add_creature: game or owner is null")
		return

	# Get the card image from card setup
	var card_img = null
	if game.has_method("get_card_image_by_name"):
		card_img = game.get_card_image_by_name(name)
	elif "cs" in game and game.cs != null:
		# cs is a property, not a method - check with "in" operator
		if game.cs.has_method("get_card_image_by_name"):
			card_img = game.cs.get_card_image_by_name(name)

	if card_img == null:
		push_error("BaseFunctions.add_creature: Could not find card: " + name)
		return

	# Clone the card image
	var cloned_card = card_img.duplicate() if card_img.has_method("duplicate") else card_img

	# Create the creature instance
	var creature_instance = null
	# CreatureFactory is a static class, just call the method directly
	creature_instance = CreatureFactory.get_creature_class(name, game, cloned_card.get_card(), cloned_card, index, owner, opponent)

	if creature_instance != null and cloned_card.has_method("set_creature"):
		cloned_card.set_creature(creature_instance)

	# Set slot as occupied
	if slot != null and slot.has_method("set_occupied"):
		slot.set_occupied(true)

	# Add to owner's slot cards
	if owner.has_method("get_slot_cards"):
		var slot_cards: Array = owner.get_slot_cards()
		if index >= 0 and index < slot_cards.size():
			slot_cards[index] = cloned_card

	# Position the card
	if slot != null and cloned_card.has_method("set_position"):
		var slot_x: float = slot.position.x if slot is Node2D else 0
		var slot_y: float = slot.position.y if slot is Node2D else 0
		# COORDINATE CONVERSION: Godot Y offset = slot.y + 6 (see battle_round_thread.gd for explanation)
		cloned_card.position = Vector2(slot_x + 5, slot_y + 6)

	# Play summon sound
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.SUMMON_DROP)

	# Add to scene
	if game.has_method("add_child"):
		game.add_child(cloned_card)

## Java: protected void swapCard(String newCardName, CardType type, String oldCardName, PlayerImage pi)
func swap_card(new_card_name: String, card_type, old_card_name: String, player_image) -> void:
	if game == null or owner_player == null:
		push_error("BaseFunctions.swap_card: game or owner_player is null")
		return

	# Get the new card image
	var new_card = null
	if game.has_method("get_card_image_by_name"):
		new_card = game.get_card_image_by_name(new_card_name)
	elif "cs" in game and game.cs != null:
		# cs is a property, not a method - check with "in" operator
		if game.cs.has_method("get_card_image_by_name"):
			new_card = game.cs.get_card_image_by_name(new_card_name)

	if new_card == null:
		push_error("BaseFunctions.swap_card: Could not find card: " + new_card_name)
		return

	# Get the player's cards of this type
	var cards: Array = []
	if owner_player.has_method("get_cards"):
		cards = owner_player.get_cards(card_type)

	# Find and remove the old card
	var old_card = null
	for card_img in cards:
		if card_img.has_method("get_card"):
			var card_ref = card_img.get_card()
			if card_ref.get_name().to_lower() == old_card_name.to_lower():
				old_card = card_img
				break

	if old_card == null:
		push_warning("BaseFunctions.swap_card: Could not find old card: " + old_card_name)
		return

	# Position new card at old card's location
	if old_card is Node2D and new_card is Node2D:
		new_card.position = old_card.position
		new_card.size = old_card.size if old_card.has_method("size") else Vector2.ZERO

	# Remove old card and add new card
	cards.erase(old_card)
	if old_card.has_method("queue_free"):
		old_card.queue_free()

	cards.append(new_card)

	# Add to scene if needed
	if player_image != null and player_image.has_method("get_slots"):
		var slots = player_image.get_slots()
		if slots.size() > 0 and slots[0].has_method("is_bottom_slots"):
			if slots[0].is_bottom_slots() and game.has_method("add_child"):
				game.add_child(new_card)

## Java: protected void tryMoveToAnotherRandomOpenSlot(PlayerImage player, CardImage ci, int currentSlot)
func try_move_to_another_random_open_slot(player, ci, current_slot: int) -> void:
	try_move_to_another_random_slot(player, ci, current_slot, true)

## Java: protected void tryMoveToAnotherRandomSlot(PlayerImage player, CardImage ci, int currentSlot, boolean mustBeOpenSlot)
func try_move_to_another_random_slot(player, ci, current_slot: int, must_be_open_slot: bool) -> void:
	if player == null or not player.has_method("get_slots"):
		return

	var slots: Array = player.get_slots()
	var valid_slots: Array = []

	for index in range(6):
		if index >= slots.size():
			continue

		var slot_img = slots[index]
		if slot_img == null:
			continue

		if must_be_open_slot:
			if slot_img.has_method("is_occupied") and not slot_img.is_occupied():
				valid_slots.append(index)
		else:
			valid_slots.append(index)

	if valid_slots.size() == 0:
		return

	# Pick a random target slot
	var target_slot: int = 0
	if valid_slots.size() == 1:
		target_slot = valid_slots[0]
	else:
		var dice: Dice = Dice.new(1, valid_slots.size())
		target_slot = valid_slots[dice.roll() - 1]

	move_card_to_another_slot(player, ci, current_slot, target_slot)

## Java: protected void moveCardToAnotherSlot(PlayerImage player, CardImage ci, int srcIndex, int destIndex)
func move_card_to_another_slot(player, ci, src_index: int, dest_index: int) -> void:
	if player == null or not player.has_method("get_slot_cards") or not player.has_method("get_slots"):
		return

	var cards: Array = player.get_slot_cards()
	var slots: Array = player.get_slots()

	if src_index < 0 or src_index >= cards.size():
		return
	if dest_index < 0 or dest_index >= cards.size():
		return

	# Check if destination slot is occupied (swap) or empty (move)
	var is_swap: bool = (cards[dest_index] != null and slots[dest_index].is_occupied())

	if is_swap:
		# Swap cards
		var card1 = cards[src_index]
		var card2 = cards[dest_index]
		cards[src_index] = card2
		cards[dest_index] = card1

		slots[src_index].set_occupied(true)
		slots[dest_index].set_occupied(true)

		# Update creature indices and positions
		if card2 != null and card2.has_method("get_creature"):
			var creature2 = card2.get_creature()
			if creature2 != null and creature2.has_method("set_index"):
				creature2.set_index(src_index)

			# Animate card2 to src position
			if card2 is Node2D:
				var tween = ci.create_tween() if ci.has_method("create_tween") else null
				if tween != null:
					# COORDINATE CONVERSION: Godot Y offset = slot.y + 6 (see battle_round_thread.gd for explanation)
					tween.tween_property(card2, "position", Vector2(slots[src_index].position.x + 5, slots[src_index].position.y + 6), 1.0)
	else:
		# Move card
		cards[src_index] = null
		cards[dest_index] = card_image

		slots[src_index].set_occupied(false)
		slots[dest_index].set_occupied(true)

	# Update card_image creature index
	if card_image != null and card_image.has_method("get_creature"):
		var creature = card_image.get_creature()
		if creature != null and creature.has_method("set_index"):
			creature.set_index(dest_index)

	# Bring card to front
	if card_image is CanvasItem and card_image.has_method("move_to_front"):
		card_image.move_to_front()

	# Play sound
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.SUMMONED)

	# Animate card_image to dest position
	if card_image is Node2D and dest_index < slots.size():
		# COORDINATE CONVERSION: Godot Y offset = slot.y + 6 (see battle_round_thread.gd for explanation)
		var dest_pos: Vector2 = Vector2(slots[dest_index].position.x + 5, slots[dest_index].position.y + 6)
		var tween = card_image.create_tween() if card_image.has_method("create_tween") else null
		if tween != null:
			tween.tween_property(card_image, "position", dest_pos, 1.0)
			await tween.finished

## Java: protected void scaleImage(CardImage ci)
func scale_image(ci) -> void:
	if ci == null or not ci is Node2D:
		return

	# Create a visual effect of scaling up then down
	var tween = ci.create_tween() if ci.has_method("create_tween") else null
	if tween != null:
		tween.tween_property(ci, "scale", Vector2(1.05, 1.05), 0.3)
		tween.tween_property(ci, "scale", Vector2(1.0, 1.0), 0.3)
