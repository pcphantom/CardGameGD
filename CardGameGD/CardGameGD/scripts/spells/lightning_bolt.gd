extends BaseSpell
class_name LightningBolt

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Calculate damage: 5 + air strength
	var value: int = 5
	if owner_player != null:
		value += owner_player.get_strength_air()

	# Deal damage to opponent player
	damage_opponent(adjust_damage(value))
