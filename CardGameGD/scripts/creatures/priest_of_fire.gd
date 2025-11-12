extends BaseCreature
class_name PriestOfFire

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Increment fire strength by 1
	if owner_player != null:
		var old_strength = owner_player.get_strength(CardType.Type.FIRE)
		owner_player.increment_strength(CardType.Type.FIRE, 1)
		var new_strength = owner_player.get_strength(CardType.Type.FIRE)
		print("[PRIEST OF FIRE] Increased fire strength: %d → %d" % [old_strength, new_strength])
	else:
		push_error("[PRIEST OF FIRE] owner_player is NULL!")
