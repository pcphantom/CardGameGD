extends BaseSpell
class_name Hellfire

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Hellfire damages all opponent creatures for 13
	# Increases fire strength by 1 for each creature killed
	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	var creatures_killed: int = 0

	for index in range(6):
		if index >= opponent_cards.size():
			continue

		var ci = opponent_cards[index]
		if ci == null:
			continue

		# Damage the creature
		var died: bool = false
		if ci.has_method("decrement_life") and game != null:
			died = ci.decrement_life(self, adjust_damage(13), game)

		# If creature died, dispose it and increment counter
		if died:
			dispose_card_image(opponent, index)
			creatures_killed += 1

	# Increase fire strength by number of creatures killed
	if owner != null and owner.has_method("get_player_info"):
		var owner_info = owner.get_player_info()
		if owner_info != null:
			owner_info.increment_strength(CardType.Type.FIRE, creatures_killed)
