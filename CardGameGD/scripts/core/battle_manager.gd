extends RefCounted
class_name BattleManager

# BattleManager
#
# Manages turn execution and battle rounds.
# Replaces BattleRoundThread.java using async/await instead of threading.
#
# Turn Structure:
# 1. Start of turn checks for all creatures
# 2. Execute summoned creature/spell (if any)
# 3. All other creatures attack (skip triplicates)
# 4. Increment player resources by 1
# 5. End of turn checks for all creatures
# 6. Enable/disable cards based on resources

var game = null
var player = null
var opponent = null
var summoned_card_image = null
var summoned_slot: int = -1
var spell_card_image = null
var targeted_card_image = null
var targeted_slot: int = -1
var targeted_card_owner_id: String = ""

func _init(game_ref = null) -> void:
	game = game_ref

func execute_turn(
	player_visual,
	opponent_visual,
	summoned_card = null,
	slot: int = -1
) -> void:
	player = player_visual
	opponent = opponent_visual
	summoned_card_image = summoned_card
	summoned_slot = slot

	if game == null or player == null or opponent == null:
		push_error("BattleManager: Null parameter, cannot execute turn")
		return

	if game.has_method("start_turn"):
		game.start_turn()

	GameManager.log_message("________________________")

	await start_of_turn_check(player)

	var player_info: Player = null
	var opponent_info: Player = null

	if player.has_method("get_player_info"):
		player_info = player.get_player_info()

	if opponent.has_method("get_player_info"):
		opponent_info = opponent.get_player_info()

	if summoned_card_image != null:
		await execute_summon(summoned_card_image, slot, player)
	elif spell_card_image != null:
		await execute_spell_cast(spell_card_image, player, opponent)

	await attack_all_creatures(player, opponent)

	if player_info != null:
		player_info.increment_strength_all(1)
		GameManager.log_message("All player resources increased by 1")

	if opponent_info != null:
		opponent_info.increment_strength_all(1)

	await enable_disable_all_cards(player_info, opponent_info)

	await end_of_turn_check(player)

	if game.has_method("finish_turn"):
		game.finish_turn()

func execute_summon(card_image, slot: int, player_visual) -> void:
	if card_image == null or not card_image.has_method("get_creature"):
		return

	var creature = card_image.get_creature()
	if creature == null or not creature.has_method("on_summoned"):
		return

	SoundManager.play_sound(SoundTypes.Sound.SUMMONED)

	creature.on_summoned()

	var card: Card = card_image.get_card() if card_image.has_method("get_card") else null
	if card != null and player_visual.has_method("get_player_info"):
		var player_info: Player = player_visual.get_player_info()
		if player_info != null:
			GameManager.emit_card_summoned(card, player_info.get_id(), slot)

	if game != null and game.has_method("get_tree"):
		await game.get_tree().create_timer(0.3).timeout

func execute_spell_cast(spell_card_image, caster_visual, target_visual) -> void:
	if spell_card_image == null or not spell_card_image.has_method("get_card"):
		return

	var spell_card: Card = spell_card_image.get_card()
	if spell_card == null:
		return

	var spell_name: String = spell_card.get_name()

	var spell = SpellFactory.get_spell_class(
		spell_name,
		game,
		spell_card,
		spell_card_image,
		caster_visual,
		target_visual
	)

	if spell == null:
		return

	if spell.has_method("set_targeted"):
		spell.set_targeted(targeted_card_image)

	if spell.has_method("set_target_slot"):
		spell.set_target_slot(targeted_slot)

	if spell.has_method("cast"):
		spell.cast()

	if caster_visual.has_method("get_player_info"):
		var caster_info: Player = caster_visual.get_player_info()
		if caster_info != null:
			GameManager.emit_spell_cast(spell_card, caster_info.get_id())

	if game != null and game.has_method("get_tree"):
		await game.get_tree().create_timer(0.5).timeout

func attack_all_creatures(player_visual, opponent_visual) -> void:
	if player_visual == null or not player_visual.has_method("get_slot_cards"):
		return

	var player_cards: Array = player_visual.get_slot_cards()

	for index in range(6):
		if index >= player_cards.size():
			continue

		var attacker = player_cards[index]
		if attacker == null:
			continue

		if summoned_card_image != null and index == summoned_slot:
			continue

		if is_triplicate_summon(summoned_card_image, attacker):
			continue

		if not attacker.has_method("get_creature"):
			continue

		var creature = attacker.get_creature()
		if creature == null or not creature.has_method("on_attack"):
			continue

		creature.on_attack()

		if game != null and game.has_method("get_tree"):
			await game.get_tree().create_timer(0.3).timeout

func start_of_turn_check(player_visual) -> void:
	if player_visual == null or not player_visual.has_method("get_slot_cards"):
		return

	var cards: Array = player_visual.get_slot_cards()
	var player_info: Player = null

	if player_visual.has_method("get_player_info"):
		player_info = player_visual.get_player_info()

	for index in range(6):
		if index >= cards.size():
			continue

		var card_image = cards[index]
		if card_image == null:
			continue

		if index == summoned_slot:
			continue

		if not card_image.has_method("get_creature"):
			continue

		var creature = card_image.get_creature()
		if creature == null:
			continue

		if player_info != null and player_info.has_method("get_player_class"):
			var player_class = player_info.get_player_class()
			if player_class != null and player_class == Specializations.VAMPIRE_LORD:
				if player_visual.has_method("increment_life"):
					player_visual.increment_life(1)

				if card_image.has_method("get_card"):
					var card: Card = card_image.get_card()
					if card != null:
						card.decrement_life(1)
						GameManager.log_message("Vampire Lord drains 1 life from %s" % card.get_name())

						if card.get_life() <= 0:
							if creature.has_method("dispose_card_image"):
								creature.dispose_card_image(player_visual, index)

		for index2 in range(6):
			if index2 >= cards.size():
				continue

			var card_image2 = cards[index2]
			if card_image2 == null or not card_image2.has_method("get_card"):
				continue

			var card2: Card = card_image2.get_card()
			if card2 != null and card2.get_name().to_lower() == "monumenttorage":
				if creature.has_method("on_attack"):
					creature.on_attack()
					GameManager.log_message("Monument to Rage triggers extra attack")

		if creature.has_method("start_of_turn_check"):
			creature.start_of_turn_check()

		if game != null and game.has_method("get_tree"):
			await game.get_tree().create_timer(0.1).timeout

func end_of_turn_check(player_visual) -> void:
	if player_visual == null or not player_visual.has_method("get_slot_cards"):
		return

	var cards: Array = player_visual.get_slot_cards()
	var creatures_to_check: Array = []

	for index in range(6):
		if index >= cards.size():
			continue

		var card_image = cards[index]
		if card_image == null:
			continue

		if not card_image.has_method("get_creature"):
			continue

		var creature = card_image.get_creature()
		if creature != null:
			creatures_to_check.append(creature)

	for creature in creatures_to_check:
		if creature.has_method("end_of_turn_check"):
			creature.end_of_turn_check()

		if game != null and game.has_method("get_tree"):
			await game.get_tree().create_timer(0.1).timeout

func is_triplicate_summon(summoned, attacker) -> bool:
	if summoned == null or attacker == null:
		return false

	if not summoned.has_method("get_card") or not attacker.has_method("get_card"):
		return false

	var summoned_card: Card = summoned.get_card()
	var attacker_card: Card = attacker.get_card()

	if summoned_card == null or attacker_card == null:
		return false

	var summoned_name: String = summoned_card.get_name().to_lower()
	var attacker_name: String = attacker_card.get_name().to_lower()

	if summoned_name == "giantspider" and attacker_name == "forestspider":
		return true

	if summoned_name == "vampireelder" and attacker_name == "initiate":
		return true

	if summoned_name == "goblinraider" and attacker_name == "goblinraider":
		return true

	if summoned_name == "insanianking" and attacker_name == "insanianpeacekeeper":
		return true

	if summoned_name == "beesoldier" and attacker_name == "beequeen":
		return true

	if summoned_name == "lemure" and attacker_name == "scrambledlemure":
		return true

	return false

func enable_disable_all_cards(player_info: Player, opponent_info: Player) -> void:
	if player_info != null:
		for card_type in Player.TYPES:
			if player_info.has_method("enable_disable_cards"):
				player_info.enable_disable_cards(card_type)

	if opponent_info != null:
		for card_type in Player.TYPES:
			if opponent_info.has_method("enable_disable_cards"):
				opponent_info.enable_disable_cards(card_type)

func get_random_opponent_slot(opponent_visual) -> int:
	if opponent_visual == null or not opponent_visual.has_method("get_slots"):
		return -1

	var slots: Array = opponent_visual.get_slots()
	var open_slots: Array = []

	for i in range(slots.size()):
		var slot = slots[i]
		if slot != null and slot.has_method("is_occupied"):
			if not slot.is_occupied():
				open_slots.append(i)

	if open_slots.is_empty():
		return -1

	var dice: Dice = Dice.new(1, open_slots.size())
	var roll: int = dice.roll()
	return open_slots[roll - 1]

func set_spell_targets(spell_card, targeted_card, target_slot_index: int, target_owner_id: String) -> void:
	spell_card_image = spell_card
	targeted_card_image = targeted_card
	targeted_slot = target_slot_index
	targeted_card_owner_id = target_owner_id
