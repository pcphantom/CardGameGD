extends BaseCreature
class_name IceGolem

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func on_attacked(attacker, damage: int) -> int:
	# Ice Golem is immune to spell damage
	var modified_damage: int = damage

	if attacker != null and "is_spell" in attacker:
		if attacker.is_spell:
			modified_damage = 0

	# Call parent implementation with modified damage
	return super.on_attacked(attacker, modified_damage)
