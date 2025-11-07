extends BaseSpell
class_name MoveFalcon

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Find DeathFalcon and move it to target slot
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
				if creature_card.get_name().to_lower() == "deathfalcon":
					# Move falcon to targeted slot
					move_card_to_another_slot(owner, ci, index, target_slot)
					break

	# Damage all opponent creatures for 4
	damage_all(opponent, adjust_damage(4))
