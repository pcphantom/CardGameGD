extends BaseCreature
class_name HolyGuard

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Holy Guard reduces damage to adjacent creatures by 2
	# This effect is handled in BaseCreature's on_attacked logic
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()
