extends BaseCreature
class_name AstralGuard

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Astral Guard reduces opponent's growth rate by -1 for ALL types
	if opposing_player != null:
		opposing_player.decrement_growth_rate_all(1)

func on_dying() -> void:
	# Reverse the growth rate penalty when astral guard dies
	if opposing_player != null:
		opposing_player.increment_growth_rate_all(1)
	super.on_dying()

func on_attack() -> void:
	super.on_attack()
