extends BaseSpell
class_name DarkRitual

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Deal 3 damage to all opponent creatures
	damage_all(opponent, adjust_damage(3))

	# Heal all friendly creatures 3 HP
	heal_all(3)
