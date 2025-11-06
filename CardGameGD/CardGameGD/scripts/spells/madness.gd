extends BaseSpell
class_name Madness

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Madness damages each opponent creature for their own attack value
	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	for index in range(6):
		if index >= opponent_cards.size():
			continue

		var ci = opponent_cards[index]
		if ci == null:
			continue

		# Get creature's attack value
		var creature_attack: int = 0
		if ci.has_method("get_card"):
			var creature_card = ci.get_card()
			if creature_card != null:
				creature_attack = creature_card.get_attack()

		# Damage the creature for its own attack value
		var died: bool = false
		if ci.has_method("decrement_life"):
			if game != null:
				died = ci.decrement_life(self, adjust_damage(creature_attack), game)

		# If creature died, dispose it
		if died:
			dispose_card_image(opponent, index)
