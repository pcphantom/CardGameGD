extends BaseCreature
class_name KeeperofDeath

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Keeper of Death grants death strength when creatures die
	# This effect is handled in BaseCreature's on_dying logic
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()
