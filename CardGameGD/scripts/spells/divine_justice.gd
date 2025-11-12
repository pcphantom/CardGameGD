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
		targeted_card_image.increment_life(12, game)
		healed_index = targeted_card_image.get_creature().get_index()

	# Damage all opponent creatures 12 (except the one in the target slot)
	for index in range(6):
		if index == target_slot:
			continue

		var ci = opponent.get_slot_cards()[index]
		if ci == null:
			continue

		damage_slot(ci, index, opponent, adjust_damage(12))

	# Damage all friendly creatures 12 (except the healed creature)
	for index in range(6):
		var ci = owner.get_slot_cards()[index]
		if ci == null or index == healed_index:
			continue

		damage_slot(ci, index, owner, adjust_damage(12))
