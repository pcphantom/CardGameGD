extends BaseCreature
class_name GoblinShaman

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

	# Increase all opponent spell costs by 1
	if opposing_player != null and opposing_player.has_method("get_cards"):
		var types: Array = [
			CardType.Type.FIRE, CardType.Type.WATER, CardType.Type.AIR,
			CardType.Type.EARTH, CardType.Type.DEATH, CardType.Type.HOLY,
			CardType.Type.ILLUSION, CardType.Type.MECHANICAL, CardType.Type.DEMONIC,
			CardType.Type.CHAOS, CardType.Type.BEAST
		]

		for type in types:
			var cards: Array = opposing_player.get_cards(type)
			for ci in cards:
				if ci != null and ci.has_method("get_card"):
					var opponent_card = ci.get_card()
					if opponent_card != null and opponent_card.has_method("is_spell") and opponent_card.is_spell():
						if opponent_card.has_method("get_cost") and opponent_card.has_method("set_cost"):
							var cost: int = opponent_card.get_cost()
							opponent_card.set_cost(cost + 1)

func on_dying() -> void:
	super.on_dying()

	# Decrease all opponent spell costs by 1
	if opposing_player != null and opposing_player.has_method("get_cards"):
		var types: Array = [
			CardType.Type.FIRE, CardType.Type.WATER, CardType.Type.AIR,
			CardType.Type.EARTH, CardType.Type.DEATH, CardType.Type.HOLY,
			CardType.Type.ILLUSION, CardType.Type.MECHANICAL, CardType.Type.DEMONIC,
			CardType.Type.CHAOS, CardType.Type.BEAST
		]

		for type in types:
			var cards: Array = opposing_player.get_cards(type)
			for ci in cards:
				if ci != null and ci.has_method("get_card"):
					var opponent_card = ci.get_card()
					if opponent_card != null and opponent_card.has_method("is_spell") and opponent_card.is_spell():
						if opponent_card.has_method("get_cost") and opponent_card.has_method("set_cost"):
							var cost: int = opponent_card.get_cost()
							opponent_card.set_cost(cost - 1)
