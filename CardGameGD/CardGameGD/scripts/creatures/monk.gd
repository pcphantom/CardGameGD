extends BaseCreature
class_name Monk

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func on_dying() -> void:
	# Call parent dying logic first
	super.on_dying()

	# Monk grants +2 holy strength when it dies
	if owner_player != null:
		owner_player.increment_strength(CardType.Type.HOLY, 2)
