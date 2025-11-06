extends BaseSpell
class_name AcidicRain

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Deal 15 damage to all opponent creatures
	damage_all(opponent, adjust_damage(15))

	# Reduce all opponent elemental strengths by 1
	if opposing_player != null:
		opposing_player.decrement_strength(CardType.Type.FIRE, 1)
		opposing_player.decrement_strength(CardType.Type.AIR, 1)
		opposing_player.decrement_strength(CardType.Type.EARTH, 1)
		opposing_player.decrement_strength(CardType.Type.WATER, 1)
		opposing_player.decrement_strength(CardType.Type.OTHER, 1)
