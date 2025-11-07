extends BaseCreature
class_name Titan

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	# Call parent summon logic first
	super.on_summoned()

	# Deal 15 damage to opposing creature if there is one
	var opponent_cards: Array = []
	if opponent != null and opponent.has_method("get_slot_cards"):
		opponent_cards = opponent.get_slot_cards()

	if slot_index < opponent_cards.size():
		var ci = opponent_cards[slot_index]
		if ci != null:
			damage_slot(ci, slot_index, opponent, 15)

func on_attack() -> void:
	super.on_attack()
