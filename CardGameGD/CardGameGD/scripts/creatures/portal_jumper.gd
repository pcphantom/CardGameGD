extends BaseCreature
class_name PortalJumper

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func end_of_turn_check() -> void:
	# Stun opposing creature
	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	if slot_index < opponent_cards.size() and opponent_cards[slot_index] != null:
		if opponent_cards[slot_index].has_method("get_creature"):
			var creature = opponent_cards[slot_index].get_creature()
			if creature != null and creature.has_method("set_skip_next_attack"):
				creature.set_skip_next_attack(true)

	# Move to random slot
	try_move_to_another_random_slot(owner, card_image, slot_index, false)
