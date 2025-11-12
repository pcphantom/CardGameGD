extends BaseSpell
class_name RageofSouls

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	var inc: int = 0

	# Calculate damage: 9 + special (death) strength
	var base_damage: int = 9
	if owner_player != null:
		base_damage += owner_player.get_strength_special()

	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	# Damage all opponent creatures
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
				died = ci.decrement_life(self, adjust_damage(base_damage), game)

		# If creature died, dispose it; otherwise heal owner
		if died:
			dispose_card_image(opponent, index)
		else:
			inc += 1

	# Heal owner 2 HP per surviving creature
	if owner != null and owner.has_method("increment_life"):
		if game != null:
			owner.increment_life(inc * 2, game)
