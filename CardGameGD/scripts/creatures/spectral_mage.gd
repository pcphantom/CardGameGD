extends BaseCreature
class_name SpectralMage

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Spectral Mage damages each opponent creature for their own cost
	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	for index in range(6):
		if index >= opponent_cards.size():
			continue

		var ci = opponent_cards[index]
		if ci == null:
			continue

		# Get creature's cost
		var creature_cost: int = 0
		if ci.has_method("get_card"):
			var creature_card = ci.get_card()
			if creature_card != null:
				creature_cost = creature_card.get_cost()

		# Damage the creature for its own cost
		var died: bool = false
		if ci.has_method("decrement_life"):
			if game != null:
				died = ci.decrement_life(self, creature_cost, game)

		# If creature died, dispose it
		if died:
			dispose_card_image(opponent, index)

func on_attack() -> void:
	super.on_attack()
