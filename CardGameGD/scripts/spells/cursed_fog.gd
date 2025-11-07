extends BaseSpell
class_name CursedFog

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Deal 12 damage to all opponent creatures
	damage_all(opponent, adjust_damage(12))

	# Deal 12 damage to all friendly creatures
	damage_all(owner, adjust_damage(12))

	# Deal 3 damage to opponent player
	damage_player(opponent, adjust_damage(3))
