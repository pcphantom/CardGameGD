extends BaseCreature
class_name PriestofFire

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	print("[PRIEST OF FIRE] on_summoned() called!")

	# Call parent summon logic first
	super.on_summoned()

	# Increase fire growth rate by +1 per turn
	if owner_player != null:
		print("[PRIEST OF FIRE] Calling increment_growth_rate for FIRE")
		var old_rate = owner_player.growth_rate[CardType.Type.FIRE] if owner_player.growth_rate.has(CardType.Type.FIRE) else 0
		owner_player.increment_growth_rate(CardType.Type.FIRE, 1)
		var new_rate = owner_player.growth_rate[CardType.Type.FIRE] if owner_player.growth_rate.has(CardType.Type.FIRE) else 0
		print("[PRIEST OF FIRE] Fire growth rate: %d → %d" % [old_rate, new_rate])
	else:
		push_error("[PRIEST OF FIRE] owner_player is NULL!")

func on_dying() -> void:
	# Reverse the growth rate bonus when priest dies
	if owner_player != null:
		owner_player.decrement_growth_rate(CardType.Type.FIRE, 1)
	super.on_dying()
