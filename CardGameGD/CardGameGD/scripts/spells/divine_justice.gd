extends BaseSpell
class_name DivineJustice

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	var healed_index: int = -1

	# Heal targeted creature 12 HP
	if targeted_card_image != null:
		if targeted_card_image.has_method("increment_life"):
			if game != null:
				targeted_card_image.increment_life(12, game)

		# Get the index of healed creature
		if targeted_card_image.has_method("get_creature"):
			var creature = targeted_card_image.get_creature()
			if creature != null:
				healed_index = creature.get_index()

	# Damage all opponent creatures 12 (except the one in the target slot)
	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	for index in range(6):
		if index >= opponent_cards.size():
			continue

		# Skip the slot of the targeted creature
		if index == target_slot:
			continue

		var ci = opponent_cards[index]
		if ci == null:
			continue

		damage_slot(ci, index, opponent, adjust_damage(12))

	# Damage all friendly creatures 12 (except the healed creature)
	var owner_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()

	for index in range(6):
		if index >= owner_cards.size():
			continue

		# Skip the healed creature
		if index == healed_index:
			continue

		var ci = owner_cards[index]
		if ci == null:
			continue

		damage_slot(ci, index, owner, adjust_damage(12))
