extends BaseSpell
class_name PumpEnergy

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Increase Fire, Water, Air, and Earth powers by 1
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.FIRE, 1)
		owner_player.increment_strength(CardType.Type.AIR, 1)
		owner_player.increment_strength(CardType.Type.EARTH, 1)
		owner_player.increment_strength(CardType.Type.WATER, 1)
