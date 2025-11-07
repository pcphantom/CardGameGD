extends BaseSpell
class_name Enrage

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Find Wolverine and completely heal it, then increase attack by 2
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
			var creature_card = ci.get_card()
			if creature_card != null and creature_card.has_method("get_name"):
				if creature_card.get_name().to_lower() == "wolverine":
					# Heal to full life
					if creature_card.has_method("get_original_life") and creature_card.has_method("get_life"):
						var inc: int = creature_card.get_original_life() - creature_card.get_life()
						if ci.has_method("increment_life") and game != null:
							ci.increment_life(inc, game)

					# Increase attack by 2 permanently
					if creature_card.has_method("increment_attack"):
						creature_card.increment_attack(2)
					break
