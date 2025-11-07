extends BaseFunctions
class_name BaseCreature

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	game = game_ref
	card = card_ref
	card_image = card_image_ref
	slot_index = slot_idx
	owner = owner_ref
	opponent = opponent_ref

	if owner != null and owner.has_method("get_player_info"):
		owner_player = owner.get_player_info()

	if opponent != null and opponent.has_method("get_player_info"):
		opposing_player = opponent.get_player_info()

func on_summoned() -> void:
	# Play summon sound effect
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.SUMMONED)

	if game != null and game.has_method("log_message"):
		var class_title: String = ""
		if owner_player != null and owner_player.has_method("get_player_class"):
			var player_class = owner_player.get_player_class()
			if player_class != null:
				class_title = player_class.get_title()

		game.log_message("%s summoned %s" % [
			class_title,
			card.get_cardname() if card != null else "Unknown"
		])

	var cost: int = card.get_cost() if card != null else 0

	if owner_player != null and card != null:
		owner_player.decrement_strength(card.get_type(), cost)

	if card != null and card.get_self_inflicting_damage() > 0:
		var self_damage: int = card.get_self_inflicting_damage()
		if game != null and game.has_method("log_message"):
			game.log_message("%s inflicts %d damage to owner" % [
				card.get_cardname(),
				self_damage
			])
		if owner != null and owner.has_method("decrement_life"):
			owner.decrement_life(self_damage)

	var nl: int = slot_index - 1
	var nr: int = slot_index + 1

	var name: String = card.get_name().to_lower() if card != null else ""

	if name == "minotaurcommander":
		enhance_attack_all(owner, 1)

	var team_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		team_cards = owner.get_slot_cards()

	for index in range(6):
		if index == slot_index:
			continue
		if index >= team_cards.size():
			continue
		var ci = team_cards[index]
		if ci == null:
			continue
		if ci.has_method("get_card"):
			var team_card: Card = ci.get_card()
			if team_card.get_name().to_lower() == "minotaurcommander":
				if card != null:
					card.increment_attack(1)

	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	if slot_index < opponent_cards.size() and opponent_cards[slot_index] != null:
		var opp_card = opponent_cards[slot_index]
		if opp_card.has_method("get_card"):
			if opp_card.get_card().get_name().to_lower() == "oblinhero":
				if opp_card.has_method("get_creature"):
					var bc = opp_card.get_creature()
					if bc != null and bc.has_method("try_move_to_another_random_open_slot"):
						bc.try_move_to_another_random_open_slot(opponent, opp_card, slot_index)

	if nl >= 0 and nl < team_cards.size() and team_cards[nl] != null:
		var left_neighbor: String = team_cards[nl].get_card().get_name().to_lower()

		if left_neighbor == "merfolkoverlord":
			on_attack()

		if left_neighbor == "orcchieftain":
			if card != null:
				card.increment_attack(2)

		if name == "orcchieftain":
			team_cards[nl].get_card().increment_attack(2)

		if name == "goblinhero":
			if card != null:
				card.increment_attack(2)

	if nr <= 5 and nr < team_cards.size() and team_cards[nr] != null:
		var right_neighbor: String = team_cards[nr].get_card().get_name().to_lower()

		if right_neighbor == "merfolkoverlord":
			on_attack()

		if right_neighbor == "orcchieftain":
			if card != null:
				card.increment_attack(2)

		if name == "orcchieftain":
			team_cards[nr].get_card().increment_attack(2)

		if name == "goblinhero":
			if card != null:
				card.increment_attack(2)

func on_attack() -> void:
	if must_skip_next_attack:
		must_skip_next_attack = false
		return

	# Play attack sound effect
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.ATTACK)

	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	for index in range(6):
		if index >= opponent_cards.size():
			continue
		var ci = opponent_cards[index]
		if ci == null:
			continue
		if ci.has_method("get_card"):
			var opp_card: Card = ci.get_card()
			if opp_card.get_name().to_lower() == "ancienthorror":
				var cost: int = card.get_cost() if card != null else 0
				var oppt_control_strength: int = 0
				if opposing_player != null:
					oppt_control_strength = opposing_player.get_strength_special()
				if cost < oppt_control_strength:
					if game != null and game.has_method("log_message"):
						game.log_message("%s skips the attack" % card.get_name())
					if game != null and game.has_method("play_sound"):
						game.play_sound("negative_effect")
					return

	var attack: int = card.get_attack() if card != null else 0

	var enemy_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		enemy_cards = opponent.get_slot_cards()

	if slot_index < enemy_cards.size() and enemy_cards[slot_index] != null:
		damage_slot(enemy_cards[slot_index], slot_index, opponent, attack)
	else:
		inflict_damage_to_player(opponent, attack)

	if game != null and game.has_method("move_card_actor_on_battle"):
		game.move_card_actor_on_battle(card_image, owner)

	var owner_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()

	for index in range(6):
		if index >= owner_cards.size():
			continue
		var ci = owner_cards[index]
		if ci == null:
			continue
		if ci.has_method("get_card"):
			var owner_card: Card = ci.get_card()
			if owner_card.get_name().to_lower() == "monumenttorage":
				owner_card.decrement_life(attack)

func on_attacked(_attacker, damage: int) -> int:
	var nl: int = slot_index - 1
	var nr: int = slot_index + 1

	var team_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		team_cards = owner.get_slot_cards()

	var opposing_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opposing_cards = opponent.get_slot_cards()

	var modified_damage: int = damage

	if slot_index < opposing_cards.size() and opposing_cards[slot_index] != null:
		if opposing_cards[slot_index].has_method("get_card"):
			var opposing_card_name: String = opposing_cards[slot_index].get_card().get_name().to_lower()
			if opposing_card_name == "justicar":
				modified_damage = modified_damage * 2

	if nl >= 0 and nl < team_cards.size() and team_cards[nl] != null:
		if team_cards[nl].has_method("get_card"):
			var left_neighbor: String = team_cards[nl].get_card().get_name().to_lower()
			if left_neighbor == "holyguard":
				modified_damage = modified_damage - 2

	if nr <= 5 and nr < team_cards.size() and team_cards[nr] != null:
		if team_cards[nr].has_method("get_card"):
			var right_neighbor: String = team_cards[nr].get_card().get_name().to_lower()
			if right_neighbor == "holyguard":
				modified_damage = modified_damage - 2

	if modified_damage < 0:
		modified_damage = 0

	for index in range(6):
		if index >= team_cards.size():
			continue
		var ci = team_cards[index]
		if ci == null:
			continue
		if ci.has_method("get_card"):
			if ci.get_card().get_name().to_lower() == "reaver":
				ci.get_card().decrement_life(modified_damage)
				if game != null and game.has_method("animate_damage_text"):
					game.animate_damage_text(modified_damage, card_image)
				return modified_damage

	if card != null:
		card.decrement_life(modified_damage)

	if game != null and game.has_method("animate_damage_text"):
		game.animate_damage_text(modified_damage, card_image)

	return modified_damage

func on_dying() -> void:
	# Play death sound effect
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.NEGATIVE_EFFECT)

	var nl: int = slot_index - 1
	var nr: int = slot_index + 1

	var name: String = card.get_name().to_lower() if card != null else ""

	var team_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		team_cards = owner.get_slot_cards()

	var opposing_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opposing_cards = opponent.get_slot_cards()

	if name == "minotaurcommander":
		enhance_attack_all(owner, -1)

	if nl >= 0 and nl < team_cards.size() and team_cards[nl] != null:
		if name == "orcchieftain":
			team_cards[nl].get_card().decrement_attack(2)
		if name == "minotaurcommander":
			team_cards[nl].get_card().decrement_attack(1)
		if team_cards[nl].has_method("get_card"):
			if team_cards[nl].get_card().get_name().to_lower() == "goblinhero":
				team_cards[nl].get_card().decrement_attack(2)

	if nr <= 5 and nr < team_cards.size() and team_cards[nr] != null:
		if name == "orcchieftain":
			team_cards[nr].get_card().decrement_attack(2)
		if name == "minotaurcommander":
			team_cards[nr].get_card().decrement_attack(1)
		if team_cards[nr].has_method("get_card"):
			if team_cards[nr].get_card().get_name().to_lower() == "goblinhero":
				team_cards[nr].get_card().decrement_attack(2)

	for index in range(6):
		if index >= opposing_cards.size():
			continue
		var ci = opposing_cards[index]
		if ci == null:
			continue
		if not ci.has_method("get_card"):
			continue

		var opp_card_name: String = ci.get_card().get_name().to_lower()

		if opp_card_name == "ghoul":
			ci.get_card().increment_attack(1)
			if game != null and game.has_method("play_sound"):
				game.play_sound("positive_effect")

		if opp_card_name == "keeperofdeath":
			if ci.has_method("get_creature"):
				var bc = ci.get_creature()
				if bc != null and bc.owner_player != null:
					bc.owner_player.increment_strength(CardType.Type.DEATH, 1)
					if game != null and game.has_method("play_sound"):
						game.play_sound("positive_effect")

		if opp_card_name == "goblinlooter":
			var dice: Dice = Dice.new(1, 5)
			var type: CardType.Type = Player.TYPES[dice.roll() - 1]
			if ci.has_method("get_creature"):
				var bc = ci.get_creature()
				if bc != null and bc.owner_player != null:
					bc.owner_player.increment_strength(type, 1)
					if game != null and game.has_method("play_sound"):
						game.play_sound("positive_effect")

	for index in range(6):
		if index >= team_cards.size():
			continue
		var ci = team_cards[index]
		if ci == null:
			continue
		if not ci.has_method("get_card"):
			continue

		var team_card_name: String = ci.get_card().get_name().to_lower()

		if team_card_name == "keeperofdeath":
			if ci.has_method("get_creature"):
				var bc = ci.get_creature()
				if bc != null and bc.owner_player != null:
					bc.owner_player.increment_strength(CardType.Type.DEATH, 1)
					if game != null and game.has_method("play_sound"):
						game.play_sound("positive_effect")

		if team_card_name == "goblinlooter":
			var dice: Dice = Dice.new(1, 5)
			var type: CardType.Type = Player.TYPES[dice.roll() - 1]
			if ci.has_method("get_creature"):
				var bc = ci.get_creature()
				if bc != null and bc.owner_player != null:
					bc.owner_player.increment_strength(type, 1)
					if game != null and game.has_method("play_sound"):
						game.play_sound("positive_effect")

func start_of_turn_check() -> void:
	pass

func end_of_turn_check() -> void:
	pass

func get_index() -> int:
	return slot_index

func set_index(index: int) -> void:
	slot_index = index

func must_skip_next_attack_check() -> bool:
	return must_skip_next_attack

func set_skip_next_attack(flag: bool) -> void:
	must_skip_next_attack = flag
	if flag and game != null and game.has_method("play_sound"):
		game.play_sound("negative_effect")

# Damage/attack functions
func damage_opponent(amount: int) -> void:
	# TODO: Implement opponent damage
	if opposing_player != null:
		opposing_player.decrement_life(amount)

func damage_player(amount: int) -> void:
	# TODO: Implement player damage
	if owner_player != null:
		owner_player.decrement_life(amount)

func damage_all_except_current_index(amount: int, exclude_index: int) -> void:
	# TODO: Implement AOE damage
	pass

# Card manipulation functions
func swap_card(target_slot: int) -> void:
	# TODO: Implement card swap
	pass

func add_creature(creature_name: String, slot_index_param: int) -> void:
	# TODO: Implement creature summoning
	pass

# Movement functions
func try_move_to_another_random_slot() -> bool:
	# TODO: Implement random movement
	return false

func try_move_to_another_random_open_slot(owner_ref, card_visual, current_index: int) -> bool:
	# TODO: Implement random movement to open slot
	return false

func move_card_to_another_slot(from_slot: int, to_slot: int) -> void:
	# TODO: Implement card movement
	pass

# Utility functions
func scale_image(scale_factor: float) -> void:
	# TODO: Implement image scaling
	pass
