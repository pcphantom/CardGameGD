extends BaseSpell
class_name StoneRain

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Deal 25 damage to all opponent creatures
	damage_all(opponent, adjust_damage(25))

	# Deal 25 damage to all friendly creatures
	damage_all(owner, adjust_damage(25))
