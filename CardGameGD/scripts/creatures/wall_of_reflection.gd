extends BaseCreature
class_name WallOfReflection

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	# Wall of Reflection does not attack
	pass

func on_attacked(attacker, damage: int) -> int:
	# Take damage normally
	var actual_damage: int = super.on_attacked(attacker, damage)

	# Reflect the same amount of damage back to opponent
	damage_opponent(actual_damage)

	return actual_damage
