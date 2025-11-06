extends BaseCreature
class_name Basilisk

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()
	swap_card("Gaze", CardType.Type.BEAST, "Basilisk", owner)

func on_dying() -> void:
	super.on_dying()
	swap_card("Basilisk", CardType.Type.BEAST, "Gaze", owner)

func end_of_turn_check() -> void:
	# Deal 4 damage to each opponent creature with 8 or less life
	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	for index in range(6):
		if index >= opponent_cards.size():
			continue

		var ci = opponent_cards[index]
		if ci == null:
			continue

		# Check creature's current life
		if ci.has_method("get_card"):
			var creature_card = ci.get_card()
			if creature_card != null and creature_card.has_method("get_life"):
				if creature_card.get_life() <= 8:
					damage_slot(ci, index, opponent, 4)
