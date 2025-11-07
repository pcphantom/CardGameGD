extends BaseCreature
class_name Bargul

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Deal 4 damage to all opponent creatures
	damage_all(opponent, 4)

	# Deal 4 damage to all friendly creatures except self
	var owner_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()

	for index in range(6):
		if index >= owner_cards.size():
			continue

		var ci = owner_cards[index]
		if ci == null or index == slot_index:
			continue

		# Damage the friendly creature
		damage_slot(ci, index, owner, 4)
