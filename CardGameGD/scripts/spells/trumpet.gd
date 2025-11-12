extends BaseSpell
class_name Trumpet

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	super.on_cast()

	# Increase Beast power by 1
	owner_player.increment_strength(CardType.Type.BEAST, 1)
