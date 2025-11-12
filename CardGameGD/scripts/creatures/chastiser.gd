extends BaseCreature
class_name Chastiser

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

func on_attack() -> void:
	super.on_attack()

func start_of_turn_check() -> void:
	# Java: card.setAttack(card.getOriginalAttack()); (line 26)
	# Reset attack to original value at start of turn
	if card != null:
		card.set_attack(card.get_original_attack())
