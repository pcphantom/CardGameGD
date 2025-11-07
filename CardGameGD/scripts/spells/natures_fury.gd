extends BaseSpell
class_name NaturesFury

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Collect attack values of all friendly creatures
	var attacks: Array = [0, 0, 0, 0, 0, 0]

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
			if creature_card != null:
				attacks[index] = creature_card.get_attack()

	# Sort attacks ascending
	attacks.sort()

	# Damage is sum of two highest attacks (last two elements after sorting)
	var damage: int = attacks[4] + attacks[5]

	# Deal damage to opponent player
	damage_opponent(adjust_damage(damage))
