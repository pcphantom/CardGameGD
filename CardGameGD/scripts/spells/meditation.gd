extends BaseSpell
class_name Meditation

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Meditation boosts Air, Fire, and Earth strengths by 1 each
	owner_player.increment_strength(CardType.Type.AIR, 1)
	owner_player.increment_strength(CardType.Type.FIRE, 1)
	owner_player.increment_strength(CardType.Type.EARTH, 1)
