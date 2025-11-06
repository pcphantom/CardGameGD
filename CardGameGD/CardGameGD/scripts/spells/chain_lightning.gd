extends BaseSpell
class_name ChainLightning

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Deal 9 damage to all opponent creatures
	damage_all(opponent, adjust_damage(9))

	# Deal 9 damage to opponent player
	damage_opponent(adjust_damage(9))
