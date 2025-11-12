extends BaseSpell
class_name DrainSouls

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	var count: int = 0

	# Destroy all friendly creatures
	for index in range(6):
		var ci = owner.get_slot_cards()[index]
		if ci == null:
			continue
		dispose_card_image(owner, ci.get_creature().get_index())
		count += 1

	# Destroy all opponent creatures
	for index in range(6):
		var ci = opponent.get_slot_cards()[index]
		if ci == null:
			continue
		dispose_card_image(opponent, ci.get_creature().get_index())
		count += 1

	# Heal owner 2 HP per creature destroyed
	var heal: int = count * 2
	owner.increment_life(heal, game)

	# Swap this card with RageofSouls in the player's deck
	swap_card("RageofSouls", CardType.Type.DEATH, "DrainSouls", owner)
