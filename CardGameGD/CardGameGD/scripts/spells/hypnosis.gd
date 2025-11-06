extends BaseSpell
class_name Hypnosis

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Hypnosis finds the 2 highest attack creatures and makes them attack their owner
	var attacks: Array = [0, 0, 0, 0, 0, 0]

	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	# Collect all attack values
	for index in range(6):
		if index >= opponent_cards.size():
			continue

		var ci = opponent_cards[index]
		if ci == null:
			continue

		if ci.has_method("get_card"):
			var creature_card = ci.get_card()
			if creature_card != null:
				attacks[index] = creature_card.get_attack()

	# Sort attacks ascending
	attacks.sort()

	# Find the 2 creatures with highest attack (attacks[5] and attacks[4])
	var hypnotized_cards: Array = [null, null]

	for index in range(6):
		if index >= opponent_cards.size():
			continue

		var ci = opponent_cards[index]
		if ci == null:
			continue

		if ci.has_method("get_card"):
			var creature_card = ci.get_card()
			if creature_card != null:
				var creature_attack: int = creature_card.get_attack()

				# Highest attack creature
				if attacks[5] == creature_attack and hypnotized_cards[0] == null:
					hypnotized_cards[0] = ci
					continue

				# Second highest attack creature
				if attacks[4] == creature_attack and hypnotized_cards[1] == null:
					hypnotized_cards[1] = ci
					continue

	# Make the hypnotized creatures attack their owner
	for ci in hypnotized_cards:
		if ci == null:
			continue

		# Scale the image for visual feedback
		scale_image(ci)

		# Damage the opponent player
		if ci.has_method("get_card"):
			var creature_card = ci.get_card()
			if creature_card != null:
				var creature_attack: int = creature_card.get_attack()
				damage_player(opponent, adjust_damage(creature_attack))
