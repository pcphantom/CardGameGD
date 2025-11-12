extends BaseSpell
class_name Enrage

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Find Wolverine and completely heal it, then increase attack by 2
	for index in range(6):
		var ci = owner.get_slot_cards()[index]
		if ci == null or ci.get_card().get_name().to_lower() != "wolverine":
			continue

		var inc: int = ci.get_card().get_original_life() - ci.get_card().get_life()
		ci.increment_life(inc, game)
		ci.get_card().increment_attack(2)
		break
