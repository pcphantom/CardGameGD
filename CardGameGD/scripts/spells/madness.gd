extends BaseSpell
class_name Madness

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Madness damages each opponent creature for their own attack value
	for index in range(6):
		var ci = opponent.get_slot_cards()[index]
		if ci == null:
			continue

		var died: bool = ci.decrement_life(self, adjust_damage(ci.get_card().get_attack()), game)

		# If creature died, dispose it
		if died:
			dispose_card_image(opponent, index)
