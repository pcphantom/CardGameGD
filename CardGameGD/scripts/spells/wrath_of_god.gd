extends BaseSpell
class_name WrathOfGod

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	var inc: int = 0

	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	# Damage all opponent creatures for 12
	for index in range(6):
		if index >= opponent_cards.size():
			continue

		var ci = opponent_cards[index]
		if ci == null:
			continue

		# Apply damage
		var died: bool = false
		if ci.has_method("decrement_life"):
			if game != null:
				died = ci.decrement_life(self, adjust_damage(12), game)

		# If creature died, dispose it; otherwise count it
		if died:
			dispose_card_image(opponent, index)
		else:
			inc += 1

	# Gain +1 holy strength per surviving creature
	if owner != null and owner.has_method("get_player_info"):
		var player_info = owner.get_player_info()
		if player_info != null:
			player_info.increment_strength(CardType.Type.HOLY, inc)
