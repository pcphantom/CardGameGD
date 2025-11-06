extends BaseCreature
class_name Griffin

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# If air strength >= 5, deal 5 damage to opponent player
	if owner_player != null:
		var air_strength: int = owner_player.get_strength_air()
		if air_strength >= 5:
			damage_player(opponent, 5)
