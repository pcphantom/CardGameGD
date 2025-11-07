extends BaseCreature
class_name Angel

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Angel grants +3 holy strength on summon
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.HOLY, 3)

func on_attack() -> void:
	super.on_attack()
