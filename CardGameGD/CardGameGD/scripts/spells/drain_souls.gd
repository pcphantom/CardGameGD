extends BaseSpell
class_name DrainSouls

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	var count: int = 0

	# Destroy all friendly creatures
	var owner_cards: Array = []
	if owner != null and owner.has_method("get_slot_cards"):
		owner_cards = owner.get_slot_cards()

	for index in range(6):
		if index >= owner_cards.size():
			continue

		var ci = owner_cards[index]
		if ci == null:
			continue

		dispose_card_image(owner, index)
		count += 1

	# Destroy all opponent creatures
	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	for index in range(6):
		if index >= opponent_cards.size():
			continue

		var ci = opponent_cards[index]
		if ci == null:
			continue

		dispose_card_image(opponent, index)
		count += 1

	# Heal owner 2 HP per creature destroyed
	var heal: int = count * 2
	if owner != null and owner.has_method("increment_life"):
		if game != null:
			owner.increment_life(heal, game)

	# Swap this card with RageofSouls in the player's deck
	swap_card("RageofSouls", CardType.Type.DEATH, "DrainSouls", owner)
