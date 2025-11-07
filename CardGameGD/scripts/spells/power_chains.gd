extends BaseSpell
class_name PowerChains

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Power Chains targets an enemy elemental creature (AIR/FIRE/WATER/EARTH)
	# Deals 12 damage and reduces that element's strength by 3
	if targeted_card_image != null:
		# Get the type of the targeted creature
		var type = null
		if targeted_card_image.has_method("get_card"):
			var target_card = targeted_card_image.get_card()
			if target_card != null:
				type = target_card.get_type()

		# Only works on elemental creatures (AIR, FIRE, WATER, EARTH)
		if type != CardType.Type.AIR and type != CardType.Type.FIRE and type != CardType.Type.WATER and type != CardType.Type.EARTH:
			return

		# Damage the targeted creature
		var index: int = -1
		if targeted_card_image.has_method("get_creature"):
			var creature = targeted_card_image.get_creature()
			if creature != null and creature.has_method("get_index"):
				index = creature.get_index()

		if index >= 0:
			damage_slot(targeted_card_image, index, opponent, adjust_damage(12))

		# Reduce the opponent's strength of that element type by 3
		if opposing_player != null and opposing_player.has_method("decrement_strength"):
			opposing_player.decrement_strength(type, 3)
