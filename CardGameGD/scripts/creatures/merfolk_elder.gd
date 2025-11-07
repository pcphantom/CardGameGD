extends BaseCreature
class_name MerfolkElder

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Increment air strength by 1
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.AIR, 1)
