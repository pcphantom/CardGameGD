extends BaseCreature
class_name WallOfFire

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Deal 5 damage to all opponent creatures
	damage_all(opponent, 5)

func on_attack() -> void:
	# Wall of Fire does not attack
	pass
