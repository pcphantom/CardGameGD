extends BaseSpell
class_name Inferno

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Inferno deals 18 damage to a targeted creature, and 10 damage to all other creatures

	# Deal 18 damage to the targeted creature
	if targeted_card_image != null:
		var target_index: int = -1
		if targeted_card_image.has_method("get_creature"):
			var creature = targeted_card_image.get_creature()
			if creature != null:
				target_index = creature.get_index()

		if target_index >= 0:
			damage_slot(targeted_card_image, target_index, opponent, adjust_damage(18))

			# Deal 10 damage to all other opponent creatures
			var opponent_cards: Array = []
			if opponent != null and opponent.has_method("get_slot_cards"):
				opponent_cards = opponent.get_slot_cards()

			for i in range(6):
				if i >= opponent_cards.size():
					continue

				var ci = opponent_cards[i]
				if ci == null:
					continue

				# Skip the targeted creature
				if i == target_index:
					continue

				damage_slot(ci, i, opponent, adjust_damage(10))
