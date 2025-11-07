extends BaseCreature
class_name AncientDragon

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

	# Swap to ability card
	swap_card("BreatheFire", CardType.Type.BEAST, "AncientDragon", owner)

	# Increase all elemental powers by 1
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.FIRE, 1)
		owner_player.increment_strength(CardType.Type.AIR, 1)
		owner_player.increment_strength(CardType.Type.EARTH, 1)
		owner_player.increment_strength(CardType.Type.WATER, 1)
		owner_player.increment_strength(CardType.Type.BEAST, 1)

func on_dying() -> void:
	super.on_dying()
	swap_card("AncientDragon", CardType.Type.BEAST, "BreatheFire", owner)
