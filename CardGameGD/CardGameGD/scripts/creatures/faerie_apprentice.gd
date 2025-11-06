extends BaseCreature
class_name FaerieApprentice

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Faerie Apprentice boosts spell damage by 1
	# This effect is handled in BaseSpell's adjust_damage method
	super.on_summoned()
