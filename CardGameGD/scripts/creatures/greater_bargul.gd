extends BaseCreature
class_name GreaterBargul

func _init(game_ref, card_ref: Card, card_image_ref, slot_idx: int, owner_ref, opponent_ref) -> void:
	super._init(game_ref, card_ref, card_image_ref, slot_idx, owner_ref, opponent_ref)

func on_summoned() -> void:
	super.on_summoned()

	# Java: damageAll(opponent, 20); (line 18)
	# Damage all opponent creatures for 20
	damage_all(opponent, 20)

	# Java: for (int index = 0; index < 6; index++) (lines 20-26)
	# Damage all friendly creatures except itself for 20
	for index in range(6):
		var owner_cards: Array = []
		if owner != null and owner.has_method("get_slot_cards"):
			owner_cards = owner.get_slot_cards()

		if index >= owner_cards.size():
			continue

		var ci = owner_cards[index]
		if ci == null or index == slot_index:
			continue

		# Java: damageSlot(ci, index, owner, 20); (line 25)
		damage_slot(ci, index, owner, 20)

func start_of_turn_check() -> void:
	# Java: damagePlayer(owner, 3); (line 32)
	# Greater Bargul damages its owner for 3 each turn
	damage_player(owner, 3)
