extends BaseCreature
class_name Archangel

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Archangel fully heals all other friendly creatures
	var friendly_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		friendly_cards = owner.get_slot_cards()

	for index in range(6):
		if index >= friendly_cards.size():
			continue

		# Skip self
		if index == slot_index:
			continue

		var ci = friendly_cards[index]
		if ci == null:
			continue

		if ci.has_method("get_card"):
			var target_card = ci.get_card()
			if target_card != null:
				# Calculate how much HP to heal (original HP - current HP)
				var original_hp: int = target_card.get_original_life()
				var current_hp: int = target_card.get_life()
				var heal_amount: int = original_hp - current_hp

				# Heal the creature
				if heal_amount > 0 and ci.has_method("increment_life"):
					if game != null:
						ci.increment_life(heal_amount, game)

func on_attack() -> void:
	super.on_attack()
