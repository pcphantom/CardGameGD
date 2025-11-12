extends BaseSpell
class_name Armageddon

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Calculate damage: 8 + fire strength
	var value: int = 8 + owner_player.get_strength_fire()

	# Deal damage to all opponent creatures
	damage_all(opponent, adjust_damage(value))

	# Deal damage to all friendly creatures
	damage_all(owner, adjust_damage(value))

	# Deal damage to opponent player
	damage_opponent(adjust_damage(value))
