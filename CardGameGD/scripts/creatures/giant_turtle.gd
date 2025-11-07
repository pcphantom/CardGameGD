extends BaseCreature
class_name GiantTurtle

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func on_attacked(attacker, damage: int) -> int:
	# Giant Turtle reduces incoming damage by 5
	var reduced_damage: int = damage - 5
	if reduced_damage < 0:
		reduced_damage = 0

	# Call parent implementation with reduced damage
	return super.on_attacked(attacker, reduced_damage)
