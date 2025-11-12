extends BaseCreature
class_name PriestofFire

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Increase fire growth rate by +1 per turn
	if owner_player != null:
		owner_player.increment_growth_rate(CardType.Type.FIRE, 1)

func on_dying() -> void:
	# Reverse the growth rate bonus when priest dies
	if owner_player != null:
		owner_player.decrement_growth_rate(CardType.Type.FIRE, 1)
	super.on_dying()
