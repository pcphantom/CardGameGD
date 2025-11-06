extends BaseCreature
class_name AstralGuard

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Astral Guard reduces all opponent elemental strengths by 1
	if opposing_player != null:
		opposing_player.decrement_strength(CardType.Type.FIRE, 1)
		opposing_player.decrement_strength(CardType.Type.AIR, 1)
		opposing_player.decrement_strength(CardType.Type.EARTH, 1)
		opposing_player.decrement_strength(CardType.Type.WATER, 1)
		opposing_player.decrement_strength(CardType.Type.OTHER, 1)

func on_attack() -> void:
	super.on_attack()
