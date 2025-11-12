extends BaseSpell
class_name DivineIntervention

func _init(game_ref, card_ref: Card, card_image_ref, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, owner_ref, opponent_ref)

func on_cast() -> void:
	# Call parent cast logic first
	super.on_cast()

	# Boost all elemental strengths by 2
	if owner_player == null:
		push_error("DivineIntervention: owner_player is null!")
		return

	owner_player.increment_strength(CardType.Type.AIR, 2)
	owner_player.increment_strength(CardType.Type.FIRE, 2)
	owner_player.increment_strength(CardType.Type.EARTH, 2)
	owner_player.increment_strength(CardType.Type.WATER, 2)

	# Heal owner 10 HP
	if owner != null and owner.has_method("increment_life") and game != null:
		owner.increment_life(10, game)
		if game.has_method("log_message"):
			game.log_message("  +2 to all elements, +10 HP")
