extends BaseCreature
class_name PhantomWarrior

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func on_attacked(attacker, damage: int) -> int:
	# Phantom Warrior always takes only 1 damage regardless of the amount
	return super.on_attacked(attacker, 1)
