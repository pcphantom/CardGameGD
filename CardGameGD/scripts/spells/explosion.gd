extends BaseSpell
class_name Explosion

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Explosion targets one of your own creatures, sacrifices it, and deals 28 damage to the opposite enemy creature
	if targeted_card_image != null:
		# Get the index of the targeted friendly creature
		var index: int = -1
		if targeted_card_image.has_method("get_creature"):
			var creature = targeted_card_image.get_creature()
			if creature != null and creature.has_method("get_index"):
				index = creature.get_index()

		if index >= 0:
			# Sacrifice the friendly creature
			dispose_card_image(owner, index)

			# Deal 28 damage to the opposite enemy creature if it exists
			var opponent_cards: Array = []
			if opponent != null and opponent.has_method("get_slot_cards"):
				opponent_cards = opponent.get_slot_cards()

			if index < opponent_cards.size():
				var ci = opponent_cards[index]
				if ci != null:
					damage_slot(ci, index, opponent, adjust_damage(28))
